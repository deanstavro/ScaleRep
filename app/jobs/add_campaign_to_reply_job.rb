class AddCampaignToReplyJob < ApplicationJob
	queue_as :default

	def perform(campaign,keys)

      objArray = JSON.parse(keys)

      api_key = obj_Array["api_key"]
      puts "CAMPAIGNNN"
      puts campaign.name

			payload = { "name": campaign.name, "emailAccount": obj_Array["emails"][0], 
        "settings": {
        "EmailsCountPerDay": 10,
        "daysToFinishProspect": 3,
        "daysFromLastProspectContact": 15,
        "emailSendingDelaySeconds": 600,
        "emailPriorityType": "Equally divided between",
        "disableOpensTracking": false,
        "repliesHandlingType": "Mark person as finished",
        "enableLinksTracking": false
        }, 
      }

			begin

				response = RestClient::Request.execute(
						:method => :get ,
						:url => 'https://api.reply.io/v2/campaigns?apiKey='+ api_key,
						#:payload => payload

					)

				puts response

			rescue


				puts "did not input into reply"

			end


	end
end

