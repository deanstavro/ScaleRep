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

  	def clean_data(data_upload, client_company)
	    puts "Starting to clean data"
	    client_leads = client_company.leads
	    data_copy = Marshal.load(Marshal.dump(data_upload.data))
	    all_hash = []
	    duplicates = []
	    not_imported = []

	    puts "we got here"
	    data_copy.each_with_index do |contact, index|
			delete_row = false
			puts "and here"

			if contact["email"].present? and contact["first_name"].present?

				# Check if admin wants to ignore duplicates
				if data_upload.ignore_duplicates == false
					puts "herro"
				  	# check for duplicates
				  	if client_leads.where(:email => contact["email"]).count == 0
				  		puts "not a duplicate"
				      	default = data_upload.rules.to_s

				      	puts "check wat rules equal"
				      	if data_upload.rules.empty?
				      		puts "empty rules"
				          	# Insert the hash into the main hash
				          	all_hash << contact.to_h
				      	else

				      		begin
				      			puts "defaul different, going through rules"
					        	# Loop through rules and apply to row. if we need to delete row, break loop and delete!
					        	rules_array = data_upload.rules
					        
						        rules_array.each_with_index do |rule, index|
					          		delete_row, contact =  apply_rule(rule, contact)
					          		if delete_row == true
					            		break
					          		end
					        	end

					        	if !delete_row
					          		all_hash << contact.to_h
					        	end
					        rescue
					        	puts "could not go through data cleaning"
					        	all_hash << contact.to_h
					        end
				      	end
			  		else
			    		duplicates << contact
			    		puts contact["email"] + " exists for client. Checking duplicates. Not included into cleaned data set"
			  		end
				else
					# We are ignoring dups, we are only checking for rules
					#Check for rules
					default = '"'+ data_upload.rules.to_s + '"'
					if default == DataUpload.columns_hash["rules"].default
					  # Insert the hash into the main hash
					  all_hash << contact.to_h
					else

					    # Loop through rules and apply to row. if we need to delete row, break loop and delete!
					    rules_array = data_upload.rules
					    
					    rules_array.each_with_index do |rule, index|
					      	delete_row, contact =  apply_rule(rule, contact)
					      	if delete_row == true
					        	break
					      	end
					    end

					    if !delete_row
					      	all_hash << contact.to_h
					    end
					end

				end
			else
				puts "row has not e-mail or first name. Not included into cleaned data set"
				not_imported << contact
			end
		end
		puts "ALL HASH " + all_hash.to_s
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