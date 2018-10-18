class LeadUploadJob < ApplicationJob
	queue_as :default
	
	require 'csv'
	require 'rest-client'
	include Reply

	def perform(data_upload_object)
		puts "upload lead job has been started"
		data_copy = Marshal.load(Marshal.dump(data_upload_object.cleaned_data))
		@base_campaign = Campaign.find_by(id: data_upload_object.campaign_id)
		client_company = @base_campaign.client_company
		clients_leads = Lead.where("client_company_id =? " , data_upload_object.client_company)
		campaign_contact_count = @base_campaign.contactLimit
		# Grab the count and figure out how many campaigns are needed
		count_of_data_set = data_upload_object.count
		# Check if current campaign has leads
		number_leads_in_campaign = @base_campaign.leads.count

		if (campaign_contact_count - number_leads_in_campaign) > 0
			lead_list_copy, imported, not_imported = upload_leads(clients_leads, campaign_contact_count, number_leads_in_campaign, data_copy, @base_campaign)
			# If more leads don't exist on the lead list, we are done
			if lead_list_copy.empty?
				puts "lead list is empty. Contacts Added to Current Campaign. Job finished"
				data_upload_object.update_attributes(:imported => imported, :not_imported => not_imported)
				return
			else
				puts "more leads to upload"
				createCampaignsUploadLeads(lead_list_copy, data_upload_object, campaign_contact_count, client_company, @base_campaign, imported, not_imported)
			end	
		else
			puts "no more space in current campaign"
			createCampaignsUploadLeads(data_copy, data_upload_object, campaign_contact_count, client_company, @base_campaign, [], [])	
		end
	end


	private


	def createCampaignsUploadLeads(remaining_leads_json, data_upload_object, campaign_contact_count, client_company, base_campaign, imported, not_imported)
		puts "private method to create campaigns and upload leads"
		clients_leads = Lead.where("client_company_id =? " , client_company)
		campaigns_left =  (remaining_leads_json.count.to_f/campaign_contact_count).ceil
		puts "NUMBER OF CAMPAIGNS LEFT: " + campaigns_left.to_s

		# For each number of campaigns
		(1..campaigns_left).each do |i|
			
			# Create the campaign on the frontend
		    @campaign = Campaign.new
		    @campaign = base_campaign.dup
		    @campaign.campaign_name = base_campaign.campaign_name + " " +Time.now.getutc.to_s
		    @campaigns = Campaign.where("client_company_id =?", client_company).order('created_at DESC')

		    # Get Array of all emails
		  	email_array = get_email_accounts(client_company.replyio_keys)
		    count_dict = email_count(email_array, @campaigns)
		    # Choose correct email based on which email is running the least campaigns
		    email_to_use = choose_email(count_dict)
		    # Find the correct keys for that email to upload the campaign to that email
		    for email in email_array
	  			if email_to_use == email["emailAddress"]
	  				reply_key = email["key"]
	  				break
	  			end
		  	end

		    # Add the email account we will use to the local campaign object
		  	puts email_to_use.to_s + "  " + reply_key
		    @campaign[:emailAccount] = email_to_use.to_s
		    # Save the campaign locally
			if @campaign.save

		        # If the campaign saves, post the campaign to reply
				post_campaign = JSON.parse(post_campaign(reply_key, email_to_use, @campaign.campaign_name))
				#Add in contact_limit amount of data
				remaining_leads_json, imports, not_imports = upload_leads(clients_leads, campaign_contact_count, 0, remaining_leads_json, @campaign)

				imported << imports
				not_imported << not_imports

				# If more leads don't exist on the lead list, we are done
				if remaining_leads_json.empty?
					puts "LEAD LIST IS EMPTY"

					data_upload_object.update_attributes(:imported => imported, :not_imported => not_imported)
					puts "Contacts Added to Current Campaign. Job finished"
					return
				else
					puts "more leads"
				end
			else
				puts "Campaign Did Not Save"
			end
		end
	end



	def upload_leads(clients_leads, campaign_contact_count, number_leads_in_campaign, upload_lead_list, campaign)
		not_imported = []
		imported = []
		leads_left_to_upload_in_campaign = campaign_contact_count - number_leads_in_campaign
		# Fill in the rest of leads in the campaign
		lead_list = upload_lead_list
		lead_list_copy = []
		lead_list_copy.replace(lead_list)

		# Loop through data_object_lead list
		for le in lead_list

			if leads_left_to_upload_in_campaign == 0
				break
			end

			begin
				#Looping through contact. Strip from master list
				lead_list_copy.shift

				if le["email"].present? and le["first_name"].present?
					if clients_leads.where(:email => le["email"]).count == 0

						le[:client_company] = campaign.client_company
						le[:campaign_id] = campaign.id
						le[:status] = "cold"
						begin
							le[:full_name] = le["first_name"] + " " + le["last_name"]
						rescue
							le[:full_name] = le["first_name"]
						end

						# Call Reply
						uploaded_contact  = AddContactToReplyJob.perform_now(le,campaign.id)
						
						if uploaded_contact
							new_lead = Lead.create!(le)
							imported << new_lead
							leads_left_to_upload_in_campaign = leads_left_to_upload_in_campaign - 1
						else
							not_imported << new_lead
						end
					else

						begin
							puts le["email"] + " is a duplicate"
							dup_lead = clients_leads.find_by(email: le["email"])

							#double check not lead
							if !(%w{handed_off sent_meeting_invite blacklist handed_off_with_questions}.include?(dup_lead.status))
								
								# Call Reply
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

		return lead_list_copy, imported, not_imported
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