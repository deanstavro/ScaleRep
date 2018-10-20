class GetCampaignsFromReplyJob < ApplicationJob
    include Reply
	queue_as :default

    # Pulling Reply Campaign Metrics -> name, email_account, bounces, out of office 
    # If the client company account is live, and the campaign has reply_key and reply_id and is not archived
	def perform()
        puts "Pulling Reply Campaign Metrics for All Companies. If the client company account is live, and the campaign has reply_key and reply_id and is not archived, we retrieve its metrics from reply. if metrics can not be retrieved, the campaign is archived"
        # Loop through all companies
        client_companies = ClientCompany.where(["account_live = ? and length(replyio_keys) > ?", true, 5])
        client_companies.each do |company|
            # Loop through all un-archived campaigns that have reply_id and reply_key
            company_campaigns = company.campaigns.where("archive =?", false)
            company_campaigns.each do |campaign|
                if campaign.reply_id.to_i > 0 and campaign.reply_key.length > 0   
                    begin
                        puts "CAMPAIGN CREDENTIALS" + campaign.reply_id + " " + campaign.reply_key
                        # Call API to retrieve campaign detail. Save in Response
                        response = v1_get_campaign(campaign.reply_id.to_i, campaign.reply_key)
                        # {:id=>204390, :name=>"testing 2", :created=>"2018-10-19T23:06:38.6494193+00:00", :emailAccount=>"paul@scalerep.net", :deliveriesCount=>0, :opensCount=>0, :repliesCount=>0, :bouncesCount=>0, :optOutsCount=>0, :outOfOfficeCount=>0, :peopleCount=>0, :peopleFinished=>0, :peopleActive=>0, :peoplePaused=>0}
                        dup_response = {:campaign_name=>response[:name], :emailAccount=>response[:emailAccount], :bouncesCount => response[:bouncesCount], :outOfOfficeCount =>response[:outOfOfficeCount], :last_poll_from_reply => Time.now }

                        # Update the campaign in the local database
                        campaign.update_attributes(dup_response)
                        sleep 20
                    rescue
                        puts "COULD NOT PULL METRICS FOR CAMPAIGN " + campaign.campaign_name
                        sleep 20
                    end
                end

                if Time.now > campaign.campaign_end
                    campaign.update_attribute(:archive, !campaign.archive)
                end
            end
        end
	end


end

