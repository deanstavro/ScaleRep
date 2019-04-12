class LeadUploadJob < ApplicationJob
	queue_as :default
	require 'csv'
	require 'rest-client'
	include Reply
	include Salesforce_Integration

	def perform(data_upload_object)
		data_list = Marshal.load(Marshal.dump(data_upload_object.cleaned_data))
		base_campaign = Campaign.find_by(id: data_upload_object.campaign_id)
		client_company = base_campaign.client_company 
		# Define lead update statuses
		crm_dup, not_imported, imported = [], [], []

		# Check if current campaign still has leads to be upload
		if (base_campaign.contactLimit - base_campaign.peopleCount) > 0
			# Upload leads into the campaign, up until the contactLimit of campaign has been reached, or until data finishes uploading
			data_list, imported, not_imported, crm_dup = upload_leads( Lead.where("client_company_id =? " , data_upload_object.client_company), data_list, base_campaign)

			if data_list.empty?
				data_upload_object.update_attributes(:imported => imported, :not_imported => not_imported, :external_crm_duplicates => crm_dup)
				return
			end
		end

		#loop until the data_list is empty. Create campaigns and upload leads
		loop do 
			break if data_list.empty?
			# Create New campaign
			current_campaign_id = createCampaign(client_company, base_campaign)
			# Upload Leads and update lead counts
			data_list, imports, not_imports, current_crm_dup = upload_leads( Lead.where("client_company_id =? " , data_upload_object.client_company), data_list, Campaign.find_by(id: current_campaign_id))
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
		puts "WE ARE HERE TO MAKE MORE CAMPAIGNS"
		campaign = Campaign.new(:campaign_name => base_campaign.campaign_name + " " +Time.now.getutc.to_s, :client_company => client_company, :persona => base_campaign.persona, :contactLimit => base_campaign.contactLimit.to_i)

		puts "CAMPAIGN" + campaign.to_s
	    # Get Array of all emails
	  	email_array = get_email_accounts(client_company.replyio_keys)
	    
	    if base_campaign.email_pool and base_campaign.email_pool.count > 0
	    	#Choosing email from pool to create campaign
	    	campaign_email_pool = base_campaign.email_pool
          	email_to_use = campaign_email_pool.key(campaign_email_pool.values.min)
          	campaign_email_pool[email_to_use] += 1
          	campaign[:email_pool] = campaign_email_pool
        else
        	# Following default rules to create campaign
          	count_dict = count_campaigns_per_email(email_array, Campaign.where("client_company_id =?", client_company).order('created_at DESC'))
         	email_to_use = count_dict.key(count_dict.values.min) 
        end
	    reply_key = get_reply_key_for_campaign(email_to_use, email_array)

	    # Add the email account we will use to the local campaign object
	  	puts "email to use for reply campaign: " + email_to_use.to_s + "  " + reply_key
	    campaign[:emailAccount] = email_to_use.to_s
	    
	    # Create campaign on Reply and Locally
		response = JSON.parse(post_campaign(campaign,reply_key, email_to_use))
		campaign.save
		return campaign.id
	end


	def upload_leads(clients_leads, upload_lead_list, campaign)
		puts "IN UPLOAD LEAD METHOD"
		not_imported, imported, crm_dup = [], [], []
		number_of_leads_left_to_upload_in_campaign = campaign.contactLimit - campaign.peopleCount
		# Fill in the rest of leads in the campaign
		lead_list_copy = [].replace(upload_lead_list)

		# Loop through data_object_lead list
		for le in upload_lead_list
			puts "STILL LOOPING"
			
			break if number_of_leads_left_to_upload_in_campaign < 1
			puts number_of_leads_left_to_upload_in_campaign.to_s

			begin
				#Looping through contact. Strip from master list
				lead_list_copy.shift

				if le["email"].present? and le["first_name"].present?
					if clients_leads.where(:email => le["email"]).count == 0

						###### Update Lead Fields ############
						updateLeadFields(le, campaign)
						
						##### Call Salesforce Integration #####
						include_contact, crm_dup = checkSalesforceIntegration(campaign.client_company.salesforce, crm_dup)

						######### Upload to Campaign if Not Blacklisted #############
						if include_contact
							
							##### Call Reply To Upload #####
							uploaded_contact  = AddContactToReplyJob.perform_now(le,campaign.id)
							# If Reply uploaded contact, upload to scalerep system
							if uploaded_contact

								new_lead = Lead.create!(le)
								##### Update Account Fields #####
								account = createOrUpdateAccountFields(new_lead, campaign)
								# Update lead with account if account is not nil
								[new_lead.update_attribute(:account_id, account.id)] if account != nil

								imported << new_lead
								# Updated the number of leads we can upload in the campaign
								number_of_leads_left_to_upload_in_campaign = number_of_leads_left_to_upload_in_campaign - 1
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
									number_of_leads_left_to_upload_in_campaign = number_of_leads_left_to_upload_in_campaign - 1
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

	
	#### Update Lead Fields #####
	def updateLeadFields(le, campaign)
		le[:client_company] = campaign.client_company
		le[:campaign_id] = campaign.id
		le[:status] = "cold"
		le[:persona_id] = campaign.persona.id
	end

	##### Update Account Fields #####
	## If company_website exists, check for by company_website
	## If company_name exists, check by company_name
	def	createOrUpdateAccountFields(new_lead, campaign)
		client_company = campaign.client_company
		account = nil

		# Check if website present
		if new_lead.company_website.present?
			# Check if company exists
			account = client_company.accounts.where('lower(website) = ?', new_lead.company_website.downcase).first
			
			# Company exists with website
			if account.present?
				new_lead.update_attribute(:account_id, account.id)
			else
				#Create new account
				if new_lead.company_name.present?
					account = Account.create!(:website => new_lead.company_website, :name => new_lead.company_name, :client_company => client_company )
				else
					account = Account.create!(:website => new_lead.company_website, :client_company => client_company, :name => new_lead.company_website)
				end
			end
		# Check if company name present
		elsif new_lead.company_name.present?
			account = client_company.accounts.where('lower(name) = ?', new_lead.company_name.downcase).first
			
			if account.present?
				new_lead.update_attribute(:account_id, account.id)
			else
				account = Account.create!(:name => new_lead.company_name, :client_company => client_company)
			end
		end

		return account
	end

	def checkSalesforceIntegration(salesforce, crm_dup)			
		include_contact = true
		if !salesforce.nil? and salesforce.salesforce_integration_on
			salesforce_client = authenticate(salesforce)
			if salesforce_client != 400
				# Check Blacklist
				if salesforce.check_dup_against_existing_contact_email_option
					puts "checking against email dups"
					salesforce_contacts = find_salesforce_contact_by_email(salesforce_client, le["email"])
					puts salesforce_contacts.to_s
					if !salesforce_contacts.empty?
						puts "Lead is blacklisted on salesforce. Skip"
						include_contact = false
						crm_dup << le # Add le to dup
					end
				end
				# Upload Contact/Account to Salesforce if options toggled on
				if include_contact
					### Check if user would like account and contact to be uploaded. ###
					#### If so, call method to create_salesforce_account_and_lead
					if salesforce.upload_accounts_to_salesforce_option
						# Create or Find id of salesforce acocunt
						account_id = create_of_find_salesforce_account(salesforce, le, campaign)

						if salesforce.upload_contacts_to_salesforce_option
							lead_created = create_or_find_salesforce_lead(account_id,salesforce, le, campaign)
						end
					# If create contact but not account, don't uplaod account reference
					elsif salesforce.upload_contacts_to_salesforce_option
						lead_created = create_or_find_salesforce_lead("nil",salesforce, le, campaign)
					end
				end
			else
				puts "not uploaded to salesforce. couldn't authenticate client"
			end
		end
		return include_contact, crm_dup
	end


end