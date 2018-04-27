class AddContactsToReplyJob < ApplicationJob
	queue_as :default

	def perform(all_contacts,keys)

  		all_contacts.each do |one_hash|

  			puts "BEGIN"
  			puts one_hash["caimpaign_name"]

  			payload = { "campaignId": one_hash["campaign_name"], "email": one_hash["email"], "firstName": one_hash["first_name"], "lastName": one_hash["last_name"], "title": one_hash["title"], "company": one_hash["company"], "domain": one_hash["company_domain"], "linkedin": one_hash["linkedin"],"timezone": one_hash["timezone"] }

  			begin

  				response = RestClient::Request.execute(
							:method => :post,
							:url => 'https://api.reply.io/v1/actions/addandpushtocampaign?apiKey='+ keys,
							:payload => payload

						)

  				puts response

  			rescue


  				puts "did not input into reply"

  			end

  		end

  	end
end

