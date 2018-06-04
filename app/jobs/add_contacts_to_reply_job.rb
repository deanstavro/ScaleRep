class AddContactsToReplyJob < ApplicationJob
	queue_as :default

	def perform(all_contacts,campaign,keys)

  		all_contacts.each do |one_hash|




          @reply_campaigns = []
          for accounts in keys["accounts"]
              @reply_campaigns << JSON.parse(get_campaigns(accounts[1]["key"]))
          end

          @campaign_array = []
          for accounts in @reply_campaigns
              for campaign in accounts
                  @campaign_array << campaign
              end
          end


    			begin

              payload = { "campaignId": campaign.reply_id, "email": one_hash["email"], "firstName": one_hash["first_name"], "lastName": one_hash["last_name"], "title": one_hash["title"], "company": one_hash["company"], "domain": one_hash["company_domain"], "linkedin": one_hash["linkedin"],"timezone": one_hash["timezone"] }


    				  response = RestClient::Request.execute(
  							 :method => :post,
  							 :url => 'https://api.reply.io/v1/actions/addandpushtocampaign?apiKey='+ 'EeLPuf3EUR3YvKxnatkDLg2',
  							 :payload => payload

  						)

              sleep(15)

    				  puts response

    			rescue


    				  puts "did not input into reply"

    			end

  		end

  	end
end
