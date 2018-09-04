class Lead < ApplicationRecord
	require 'csv'
	require 'rest-client'
	require 'rubygems'
	require 'json'

	belongs_to :client_company, optional: true
	belongs_to :account, optional: true
	belongs_to :campaign, optional: true
	has_many :campaign_replies

	enum status: [:cold, :in_campaign, :not_interested, :blacklist, :interested, :handed_off, :sent_meeting_invite, :handed_off_with_questions]
	validates_uniqueness_of :email, scope: :client_company
	validates :email, presence: true
	validates :first_name, presence: true
	after_initialize :init


	def self.import_to_campaign(file, company, leads, campaign_id, column_names)

		puts "Starting lead import to campaign"
		
		lines = CSV.open(file.path).readlines
		keys = lines.delete lines.first
	
		email_exists = false
		first_name_exists = false
		
		# Check for required keys
		for key in keys
			if key != nil

				email_exists = true if key.downcase == "email"
				first_name_exists = true if key.downcase == "first_name"
			else
				puts "empty header"
			end
			
			keys.keep_if {|k,_| column_names.include? k}
		end

		# check for required fields in the header
		if first_name_exists == false
			return "first_name header not included. List not uploaded"
		elsif email_exists == false
			return "email header not included. List not uploaded"
		end

		count = 0
		data = nil
		# Open file and create json from it
		File.open(file.path, "w") do |f|
  			data_ob = lines.map do |values|
  				count = count + 1
  				!!(values =~ /^[-+]?[1-9]([0-9]*)?$/) ? values.to_i : values.to_s
    			Hash[keys.zip(values)]
  			end
  			puts JSON.pretty_generate(data_ob)
  			data = data_ob
		end

		# Create a new data_upload
		data_object = DataUpload.new
		data_object.count = count
		data_object.data = data
		data_object.campaign = Campaign.find_by(id: campaign_id)
		data_object.client_company = data_object.campaign.client_company
		data_object.save!

		# Perform later the making of the campaigns, then adding the data
		LeadUploadJob.perform_later(data_object)
		return "Data has been uploaded. A report will be generated when the upload is complete"




		if false
				not_imported = 0
				duplicates = []
				imported = 0
				rows_email_not_present = 0

				#Hash of all rows that will be inputted to reply
				all_hash = []

				CSV.foreach(file.path, headers: true) do |row|
					puts "looping through each row"

					#Take row, convert keys to lowercase, put in key,value hash
		  			new_hash = {}
		  			row.to_hash.each_pair do |k,v|
		 	  			new_hash.merge!({k.downcase => v})
		 	  			new_hash.keep_if {|k,_| column_names.include? k }
		  			end


					one_hash = new_hash.to_hash
					# If e-mail field is included
					if one_hash["email"].present?

							puts one_hash


							email = one_hash["email"]

							begin
								# check for duplicates
								if leads.where(:email => email).count == 0

									one_hash[:client_company] = company
									one_hash[:campaign_id] = campaign_id

									#This is where the account will get updated

									#lead = Lead.create!(one_hash)
									all_hash << Lead.new(one_hash.to_h)

									imported = imported + 1
								else

									duplicates << $.
								end
							rescue Exception => e
								not_imported = not_imported + 1
							end

					else
						rows_email_not_present = rows_email_not_present + 1
					end


				end
				Lead.import(all_hash)
				AddContactsToReplyJob.perform_later(all_hash,campaign_id)

				return imported.to_s + " leads imported successfully, duplicate lead rows not uploaded: "+ duplicates.to_s + ", " + rows_email_not_present.to_s + " rows without email field"
		end
	end


	def self.import_blacklist(file, company, leads, params, col)

		#Take row, convert keys to lowercase, put in key,value hash
		rows_email_not_present = 0
		not_imported = 0
		imported = 0
		duplicates = 0
  		

		#Iterate through file
		CSV.foreach(file.path, headers: true) do |row|

			#Take row, convert keys to lowercase, put in key,value hash
			new_hash = {}
  			row.to_hash.each_pair do |k,v|
 	  			new_hash.merge!({k.downcase => v})
 	  			new_hash.keep_if {|k,_| column_names.include? k }
  			end

  			one_hash = new_hash.to_hash
			# If e-mail field is included
			if one_hash["email"].present?
				email = one_hash["email"]

				puts one_hash

				#If e-mail does not exist in database
				begin

					# check for duplicates
					if leads.where(:email => email).count == 0
						puts "email is not duplicate"
						lead = Lead.create!(one_hash)
						event = CampaignReply.create!(one_hash)


						#event.update_attributes(:status => "blacklist", :client_company => company, :lead => lead)
						lead.update_attributes(:status => "blacklist", :client_company => company)

					else
						event = CampaignReply.create!(one_hash)
						lead = leads.find_by(email: email)

						event.update_attributes(:client_company_id => company.id, :lead_id => lead.id, :status => "blacklist" )
						#event.update_attributes(:status => "blacklist")
						lead.update_attributes(:status => "blacklist", :client_company => company)
						puts "This is a duplicate. Get the lead and change it to blacklist"
						duplicates = duplicates + 1
					end

					imported = imported + 1

				rescue Exception => e
					not_imported = not_imported + 1
				end
			else
				rows_email_not_present = rows_email_not_present + 1

			end




		#Add it to the company and move it to blacklist as status

		#If email exists, move status to blacklist

		end


		return imported.to_s + " leads imported successfully to blacklist, duplicate lead rows moved to blacklist: "+ duplicates.to_s + ", " + rows_email_not_present.to_s + " rows without email field, not imported: " + not_imported.to_s

	end

	private


	def one_hash
		one_hash.require(:lead).permit(:decision_maker, :internal_notes, :email_in_contact_with, :date_sourced, :client_company, :campaign_id, :contract_sent, :contract_amount, :timeline, :project_scope, :email_handed_off_too, :meeting_time, :email, :first_name, :last_name, :hunter_score, :hunter_date, :title, :phone_type, :phone_number, :city, :state, :country, :linkedin, :timezone, :address, :meeting_taken, :full_name, :status, :company_name, :company_website, :account_id)
		#
		#id, decision_maker, internal_notes, email_in_contact_with, date_sourced
    	# created_at, updated_at, client_company_id, campaign_id, contract_sent,
    	# contract_amount, timeline, project_scope, email_handed_off_too, meeting_time,
    	# email, first_name, last_name, hunter_score, hunter_date, title, phone_type,
    	# phone_number, city, state, country, linkedin, timezone, address, meeting_taken,
    	# full_name, status, company_name, company_website, account_id
	end





    def init
      self.contract_amount ||= 0           #will set the default value only if it's nil
      self.contract_sent ||= :no
    end



end
