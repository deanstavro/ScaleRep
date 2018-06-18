class AddContactsToReplyJob < ApplicationJob
	queue_as :default

	def perform(all_contacts,campaign)

      @campaign = Campaign.find_by(id: campaign)

      puts "Starting to upload into reply"

  		all_contacts.each do |one_hash|
        puts "STATS"
        puts @campaign.reply_id
        puts 'https://api.reply.io/v1/actions/addandpushtocampaign?apiKey='+ @campaign.reply_key
        puts one_hash["email"]
        puts one_hash["first_name"]
        puts one_hash["last_name"]


    			begin

              payload = { "campaignId": @campaign.reply_id, "email": one_hash["email"], "firstName": one_hash["first_name"], "lastName": one_hash["last_name"], "company": one_hash["company_name"], "title": one_hash["title"] }


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