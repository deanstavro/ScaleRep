class GetCampaignsFromReplyJob < ApplicationJob
    include Reply
	queue_as :default

	def perform()
    puts "Pulling Reply Campaign Metrics for All Companies. If the client company account is live, and the campaign has reply_key and reply_id and is not archived, we retrieve its metrics from reply. if metrics can not be retrieved, the campaign is archived"

    # Pulling Reply Campaign Metrics for All Companies. 
    # If the client company account is live, and the campaign has reply_key and reply_id and is not archived
    # we retrieve its metrics from reply. if metrics can not be retrieved, the campaign is archived
    # The metrics being pulled are all but opensCount and uniqueOpens


    # Loop through all companies
    client_companies = ClientCompany.where("account_live =?", true)

    client_companies.each do |company|

        # if companies reply keys exist
        if company.replyio_keys.length>0
          
            # get campaigns in which archived is false
            companies_campaigns = company.campaigns.where("archive =?", false)
          

            companies_campaigns.each do |campaign|

                if campaign.reply_id.to_i > 0
                      if campaign.reply_key.length > 0
                            begin
                                puts "CAMPAIGN CREDENTIALS" + campaign.reply_id + " " + campaign.reply_key

                                response = v1_get_campaign(campaign.reply_id.to_i, campaign.reply_key)
                                
                                response[:last_poll_from_reply] = response[:created]
                                response[:campaign_name] = response[:name]
                                response.delete(:name)
                                response.delete(:opensCount)
                                response.delete(:peopleCount)
                                response.delete(:id)
                                response.delete(:created)
                                response.delete_if { |k, v| v.nil? }

                                puts "RESPONSE BEFORE"
                                puts response

                                # Update the campaign in the local database
                                campaign.update_attributes(response)

                                sleep 20
                            rescue
                                puts "COULD NOT PULL METRICS FOR CAMPAIGN " + campaign.campaign_name

                                #archive the campaign
                                campaign.update_attribute(:archive, true)
                                puts "Could not pull data. Campaign archived"
                                sleep 20
                            end
                      end
                end
            
            end
        end
    end


	end



end

