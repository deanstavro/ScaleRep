class LeadUploadJob < ApplicationJob
	queue_as :default
	
	require 'csv'
	require 'rest-client'
	include Reply
	include Salesforce_Integration

	
	def perform(data_upload_object)
		puts "upload lead job has been started"
		data_list = Marshal.load(Marshal.dump(data_upload_object.cleaned_data))
		base_campaign = Campaign.find_by(id: data_upload_object.campaign_id)
		client_company = base_campaign.client_company
		clients_leads = Lead.where("client_company_id =? " , data_upload_object.client_company)

		crm_dup = []
		not_imported = []
		imported = []

		# Check if current campaign still has leads to be upload
		if (base_campaign.contactLimit - base_campaign.peopleCount) > 0
			# Upload leads into the campaign, up until the contactLimit of campaign has been reached, or until data finishes uploading
			data_list, imported, not_imported, crm_dup = upload_leads(clients_leads, data_list, base_campaign)
			if data_list.empty?
				data_upload_object.update_attributes(:imported => imported, :not_imported => not_imported, :external_crm_duplicates => crm_dup)
				return
			end
		end

		#loop until the data_list is empty. Create campaigns and upload leds
		loop do 
			break if data_list.empty?
			
			# Create campaign
			current_campaign_id = createCampaign(client_company, base_campaign)
			current_campaign = Campaign.find_by(id: current_campaign_id)
			puts "New Campaign Created: " + current_campaign.campaign_name
			
			# Upload leads into new campaign
			clients_leads = Lead.where("client_company_id =? " , data_upload_object.client_company)
			data_list, imports, not_imports, current_crm_dup = upload_leads(clients_leads, data_list, current_campaign)

			# Update lead counts
			imported += imports
			not_imported += not_imports
			crm_dup += current_crm_dup
		end

		# update data_upload fields when upload is complete
		data_upload_object.update_attributes(:imported => imported, :not_imported => not_imported, :external_crm_duplicates => crm_dup)
		return
	end




	private

	def createCampaign(client_company, base_campaign)
		campaign = Campaign.new(:campaign_name => base_campaign.campaign_name + " " +Time.now.getutc.to_s, :client_company => client_company, :persona => base_campaign.persona, :contactLimit => base_campaign.contactLimit)
	    puts "NEW CAMPAIGN: " + campaign.to_s
	    campaigns = Campaign.where("client_company_id =?", client_company).order('created_at DESC')

	    # Get Array of all emails
	  	email_array = get_email_accounts(client_company.replyio_keys)
	    count_dict = email_count(email_array, campaigns)
	    email_to_use = choose_email(count_dict)

	    # Find the correct keys for that email to upload the campaign to that email
	    for email in email_array
  			if email_to_use == email["emailAddress"]
  				reply_key = email["key"]
  				break
  			end
	  	end

	    # Add the email account we will use to the local campaign object
	  	puts "email to use for reply campaign: " + email_to_use.to_s + "  " + reply_key
	    campaign[:emailAccount] = email_to_use.to_s
	    
	    # Save the campaign locally
		if campaign.save
	        # If the campaign saves, post the campaign to reply
			response = JSON.parse(post_campaign(campaign,reply_key, email_to_use))
		end

		return campaign.id
	end


	def upload_leads(clients_leads, upload_lead_list, campaign)
		not_imported = []
		imported = []
		crm_dup = []
		leads_left_to_upload_in_campaign = campaign.contactLimit - campaign.peopleCount
		# Fill in the rest of leads in the campaign
		lead_list_copy = []
		lead_list_copy.replace(upload_lead_list)

		# Loop through data_object_lead list
		for le in upload_lead_list

			if leads_left_to_upload_in_campaign == 0
				break
			end

			begin
				#Looping through contact. Strip from master list
				lead_list_copy.shift

				if le["email"].present? and le["first_name"].present?
					if clients_leads.where(:email => le["email"]).count == 0

						
						###### Update Lead Fields ############
						le[:client_company] = campaign.client_company
						le[:campaign_id] = campaign.id
						le[:status] = "cold"
						begin
							le[:full_name] = le["first_name"] + " " + le["last_name"]
						rescue
							le[:full_name] = le["first_name"]
						end
						
						

						##### Call Salesforce Integration #####

						include_contact = true
						salesforce = campaign.client_company.salesforce
						if !salesforce.nil? and salesforce.salesforce_integration_on
							
							salesforce_client = authenticate(salesforce)
							puts "Salesforce Client Authenticated"
							# Check Blacklist
							if salesforce.check_dup_against_existing_contact_email_option
								puts "checking against email dups"
								salesforce_contacts = salesforce_contact_by_email(salesforce_client, salesforce, le)
								if !salesforce_contacts.empty?
									include_contact = false
									crm_dup << le # Add le to dup
								end
							end

							# Upload Contact/Account to Salesforce if options toggled on
							if include_contact
								puts "create Contact"

								### Check if user would like account and contact to be uploaded. ###
								#### If so, call method to create_salesforce_account_and_lead
								if salesforce.upload_accounts_to_salesforce_option
									# Create or Find id of salesforce acocunt
									puts "finding or creating account"
									account_id = create_of_find_salesforce_account(salesforce, le, campaign)
									puts "ACCOUNT ID: " + account_id

									if salesforce.upload_contacts_to_salesforce_option
										lead_created = create_or_find_salesforce_lead(account_id,salesforce, le, campaign)
									end
								# If create contact but not account, don't uplaod account reference
								elsif salesforce.upload_contacts_to_salesforce_option
									lead_created = create_or_find_salesforce_lead("nil",salesforce, le, campaign)
								end
							end
						end



						######### Upload to Campaign if Not Blacklisted #############
						if include_contact
							##### Call Reply To Upload #####
							uploaded_contact  = AddContactToReplyJob.perform_now(le,campaign.id)
							if uploaded_contact
								new_lead = Lead.create!(le)
								imported << new_lead
								leads_left_to_upload_in_campaign = leads_left_to_upload_in_campaign - 1
							else
								not_imported << new_lead
							end
						end

					else


						#################### Duplicate Lead ###########################
						begin
							puts le["email"] + " is a duplicate"
							dup_lead = clients_leads.find_by(email: le["email"])

							#double check not lead
							if !(%w{handed_off sent_meeting_invite blacklist handed_off_with_questions}.include?(dup_lead.status))

								##### Call Reply To Upload #####
								uploaded_contact  = AddContactToReplyJob.perform_now(le,campaign.id)
								# If reply was a success
								if uploaded_contact
									dup_lead.update_attributes(:campaign_id => campaign.id, :status => :cold)
									imported << dup_lead
									leads_left_to_upload_in_campaign = leads_left_to_upload_in_campaign - 1
								else
									not_imported << dup_lead
								end
							else
								puts "lead is on the blacklist"
								not_imported << dup_lead
							end
						rescue
							puts "could not update existing lead to this campaign"
						end
					end
				else
					puts "not imported because email or first_name missing"
					not_imported << le
				end
			rescue Exception => e
				not_imported << le
				puts "Row not imported due to an error"
			end
		end

		return lead_list_copy, imported, not_imported, crm_dup
	end




	def choose_email(count_dict)

  		current_value = 1000
		current_email = ""
		count_dict.each do |key, value|

			if value < current_value
				current_value = value
				current_email = key
			end
		end

		return current_email

  	end


  	def email_count(email_array, campaign_array)
  		count_dic = Hash.new
		for email in email_array
			count_dic[email["emailAddress"]] = 0
		end
		for campaign in campaign_array
			for reply_email in email_array

				if campaign.emailAccount == reply_email["emailAddress"]
					if count_dic[campaign.emailAccount]
						count_dic[campaign.emailAccount] = count_dic[campaign.emailAccount] + 1
					else
						count_dic[campaign.emailAccount] = 1
					end
				end
			end
		end

		return count_dic
  	end



end