class AddContactsToReplyJob < ApplicationJob
	queue_as :default

	def perform(all_contacts,campaign)

      @campaign = Campaign.find_by(id: campaign)
      puts "Starting to upload into reply"

  		all_contacts.each do |one_hash|
      #ACCEPTED FIELDS ==> {"campaignId": 121, "email": "name@company.com", "firstName": "James", "lastName": "Smith", "company": "Global Tech", "city": "San Francisco", "state": "CA", "country": "US", "title": "VP of Marketing"}
          
          puts "Reply.io upload stats"
          puts "Reply Id: " + @campaign.reply_id
          puts 'https://api.reply.io/v1/actions/addandpushtocampaign?apiKey='+ @campaign.reply_key
          puts "email: " + one_hash["email"]
          puts "f-name: " + one_hash["first_name"]
          

      		begin
                payload = { "campaignId": @campaign.reply_id, "email": one_hash["email"], "firstName": one_hash["first_name"], "lastName": one_hash["last_name"], "company": one_hash["company_name"], "title": one_hash["title"], "city": one_hash["city"], "state": one_hash["state"] }

                if one_hash["last_name"].present?
                  payload["last_name"] = one_hash["last_name"]
                  puts "l-name: " + one_hash["last_name"]
                end

                if one_hash["title"].present?
                  payload["title"] = one_hash["title"]
                  puts "title: " + one_hash["title"]
                end

                if one_hash["city"].present?
                  payload["city"] = one_hash["city"]
                  puts "city: " + one_hash["city"]
                end

                if one_hash["state"].present?
                  payload["state"] = one_hash["state"]
                  puts "state: " + one_hash["state"]

                end

      				  response = RestClient::Request.execute(
      						 :method => :post,
      						 :url => 'https://api.reply.io/v1/actions/addandpushtocampaign?apiKey='+ @campaign.reply_key,
      						 :payload => payload
      					)

                sleep(10)
      				  puts response

      		rescue
      				  puts "did not input into reply"
      		end

  		end

  end
end
