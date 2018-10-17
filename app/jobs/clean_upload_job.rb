class CleanUploadJob < ApplicationJob
	queue_as :default
	
	require 'csv'
	require 'rest-client'
	include Reply

	def perform(data_upload, client_company)
    	
    	# Starting job to clean data
    	clean_data(data_upload, client_company)
      	cleaned_data = data_upload.cleaned_data
    end

	private

	# Ignores rows missing first_name or email, and stores in data_upload.not_imported
	# Ignores dups if ignore_duplicates = false, stores dups in data_upload.duplicates
	# Ignores leads that are blacklisted or handed off ==> %w{handed_off sent_meeting_invite blacklist handed_off_with_questions}
	# Cleans other data and uploads into imported 
  	def clean_data(data_upload, client_company)
	    puts "Starting to clean data" 
	    client_leads = client_company.leads
	    data_copy = Marshal.load(Marshal.dump(data_upload.data))
	    all_hash = []
	    duplicates = []
	    not_imported = []
	    rules_array = data_upload.rules

	    data_copy.each_with_index do |contact, index|
			
			delete_row = false
			blacklist_contact = false
			blacklist_array = ["handed_off","sent_meeting_invite","handed_off_with_questions", "blacklist"]

			# Check if email and first_name exist
			if !contact["email"].present? or !contact["first_name"].present?
				not_imported << contact
				puts "email or first_name does not exist. Not uploaded"
				next
			end

			lead_count = client_leads.where(["lower(email) = ?", contact["email"].downcase]).count
			puts lead_count.to_s
			# If lead exists and should not be created, continue
			if data_upload.ignore_duplicates != true and lead_count > 0
				duplicates << contact
		    	puts contact["email"] + " exists. Not uploaded"
		    	next
		    end
		    
		    # If lead is blacklist or one of the handed_off enums, skip
		    if lead_count > 0
		    	lead_array = client_leads.where(["lower(email) = ?", contact["email"].downcase])
		    	for le in lead_array
		    		if %w{handed_off sent_meeting_invite blacklist handed_off_with_questions}.include?(le.status)
		    			puts "lead is " + le.status.to_s 
		    			blacklist_contact = true
		    			not_imported << le
		    		end
		    	end
		    end
		    if blacklist_contact == true
		    	next
		    end


		    if !data_upload.rules.empty?
	      		begin
		        	# Loop through rules and apply to row. if we need to delete row, break loop and delete!
			        rules_array.each_with_index do |rule, index|
		          		delete_row, contact =  apply_rule(rule, contact)
		          		if delete_row == true
		          			not_imported << contact
		            		break
		          		end
		        	end
		        rescue
		        	puts "could not go through data cleaning"
		        end
			end
		    
		    # Add contact if cleaning dictates we should delete
		    if !delete_row
		        all_hash << contact.to_h
		        puts contact["email"] + " uploaded"
		    end

		end

		data_upload.update_attributes(:cleaned_data => all_hash, :duplicates => duplicates, :not_imported => not_imported)
  	end

  	private


	#Apply rule to contact
	def apply_rule(rule, contact)
		puts "cleaning " + contact["email"] + " with rule " + rule

		begin

		  if rule.include? "delete row"
		    rule_column = rule.split("'")[1]
		    puts "delete row " + rule_column + " with string " + contact[rule_column]

		      if contact[rule_column].include? rule.split("'")[3]
		          return true, contact
		      else
		          return false, contact
		      end

		  elsif rule.include? "delete string"
		  	puts "RULE"
		  	puts rule.to_s
		    rule_column  = rule.split("'")[3]
		    puts rule_column
		    string_delete = rule.split("'")[1]
		    puts string_delete
		    puts "delete string " + string_delete + " with string " + contact[rule_column]

		    #lower case sensitive check
		    val_cop = contact[rule_column].downcase
		    string_del_cop = string_delete.downcase

		    if val_cop.include? string_del_cop
		      contact[rule_column] = val_cop.gsub(string_delete, '')        
		      puts contact[rule_column]
		    end

		    
		    return false, contact

		  elsif rule.include? "change casing"
		    rule_column  = rule.split("'")[1]
		    check_length = rule.split("'")[3]
		    puts "delete casing " + rule_column + "for length greater than " + check_length.to_s

		    if contact[rule_column].length > check_length.to_i
		      new_value = contact[rule_column].split.map(&:capitalize).join(' ')
		      contact[rule_column] = new_value
		    end
		    
		    return false, contact

		  else 

		    puts "can't understand rule"
		    return false, contact

		  end   

		rescue
		    puts "ERROR"
		    return false, contact
		end 

	end


end