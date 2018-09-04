class LeadUploadJob < ApplicationJob
	queue_as :default
	
	require 'csv'
	require 'rest-client'
	include Reply

	def perform(data_upload_object)

		puts "upload lead job has been started"

		#From campaign, grab the number of contacts per campaign
		@base_campaign = Campaign.find_by(id: data_upload_object.campaign_id)
		puts "CAMPAIGN BASE: " + @base_campaign.to_s
		puts @base_campaign.id
		client_company = @base_campaign.client_company
		clients_leads = Lead.where("client_company_id =? " , client_company)

		# Campaign Contact Limit
		campaign_contact_count = @base_campaign.contactLimit
		puts "Base campaign contact count limit: " + campaign_contact_count.to_s
		# Grab the count and figure out how many campaigns are needed
		count_of_data_set = data_upload_object.count
		puts "Count of data set: " + count_of_data_set.to_s

		# Check if current campaign has leads
		number_leads_in_campaign = @base_campaign.leads.count
		puts "Campaign has this number of contacts: " + number_leads_in_campaign.to_s

		if (campaign_contact_count - number_leads_in_campaign) > 0

			lead_list_copy, imported, duplicated, not_imported = upload_leads(clients_leads, campaign_contact_count, number_leads_in_campaign, data_upload_object.data, @base_campaign)
		
			puts "LEAD LIST " + lead_list_copy.to_s
			puts "IMPORTED" + imported.to_s
			puts duplicated.to_s
			puts not_imported.to_s


			# If more leads don't exist on the lead list, we are done
			if lead_list_copy.empty?
				puts "LEAD LIST IS EMPTY"
				

				puts "Contacts Added to Current Campaign. Job finished"
				return
			else
				puts "have more leads"
				# Create campaigns and upload leads for the remain contacts
				createCampaignsUploadLeads(lead_list_copy, data_upload_object, campaign_contact_count, client_company, @base_campaign)

			end	
		else
			puts "no more space in current campaign"
			# The current campaign is full
			createCampaignsUploadLeads(data_upload_object.data, data_upload_object, campaign_contact_count, client_company, @base_campaign)
			
		end




	end

	private

	def createCampaignsUploadLeads(remaining_leads_json, data_upload_object, campaign_contact_count, client_company, base_campaign)
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

		    puts "email count_dict"
		    puts count_dict

		    # Choose correct email based on which email is running the least campaigns
		    email_to_use = choose_email(count_dict)

		    puts "email to use: "
		    puts email_to_use

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
				remaining_leads_json, imported, duplicated, not_imported = upload_leads(clients_leads, campaign_contact_count, 0, remaining_leads_json, @campaign)

				# If more leads don't exist on the lead list, we are done
				if remaining_leads_json.empty?
					puts "LEAD LIST IS EMPTY"
				

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
		not_imported = 0
		duplicates = []
		imported = 0
		rows_email_not_present = 0
		#Hash of all rows that will be inputted to reply
		all_hash = []



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
				# check for duplicates
				if clients_leads.where(:email => le["email"]).count == 0
					puts "Client Lead is not a duplicate. Will be created: "

					le[:client_company] = campaign.client_company
					le[:campaign_id] = campaign.id
					puts le

					all_hash << Lead.new(le.to_h)

					imported = imported + 1

					leads_left_to_upload_in_campaign = leads_left_to_upload_in_campaign - 1
					puts "NUMBER OF LEADS LEFT THAT WE CAN INPUT TO CAMPAIGN: " + leads_left_to_upload_in_campaign.to_s
					
					lead_list_copy.shift

					puts lead_list_copy

					
				else

					duplicates << $.
					puts le["email"] + " is a duplicate"
					lead_list_copy.shift
					puts lead_list_copy

				end
			rescue Exception => e
				not_imported = not_imported + 1
				puts le["email"] + " not imported"
				lead_list_copy.shift
				puts lead_list_copy
			end
				

		end

		Lead.import(all_hash)
		AddContactsToReplyJob.perform_now(all_hash,campaign.id)
		return lead_list_copy, imported, duplicates, not_imported
	end


	def choose_email(count_dict= count_dict)

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