class GetCampaignsFromReplyJob < ApplicationJob
    include Reply
	queue_as :default

	def perform()
    puts "Pulling Reply Campaign Metrics for All Companies"

    # Loop through all companies
    ClientCompany.find_each do |company|

      if company.replyio_keys.length>0
          company.campaigns.find_each do |campaign|
            puts campaign.persona

            if campaign.reply_id.to_i > 0
              if campaign.reply_key.length > 0
                begin
                    puts "CAMPAIGN CREDENTIALS"
                    puts campaign.reply_id
                    puts campaign.reply_key

                    response = v1_get_campaign(campaign.reply_id.to_i, campaign.reply_key)
                    
                    response[:last_poll_from_reply] = response[:created]
                    response[:campaign_name] = response[:name]
                    response.delete(:name)
                    response.delete(:id)
                    response.delete(:created)
                    puts response

                    
                    
                    campaign.update_attributes(response)

                    puts campaign.last_poll_from_reply


                    # Update the campaign in the local database



                    sleep 60
                rescue
                    puts "COULD NOT PULL METRICS FOR CAMPAIGN " + campaign.campaign_name
                end
              end
            end

                #call correct API to retrieve metrics


            # Get the response


            # For each metric

            
        end
      end
    end


	end

end

