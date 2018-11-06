class AddContactToReplyJob < ApplicationJob
	queue_as :default
  require 'json'
  require 'rest-client'

	
  # This job upload a contact into reply with fields campaignId,email,firstName,lastName,title,company,city,state
  def perform(contact,campaign_id)
      @campaign = Campaign.find_by(id: campaign_id)
      puts "Starting to upload " + contact.to_s + " into reply"
      uploaded_contact = false

  		begin
            payload = { "campaignId" => @campaign.reply_id, "email" => contact["email"], "firstName" => contact["first_name"], "lastName" => contact["last_name"], "company" => contact["company_name"], "title" => contact["title"], "city" => contact["city"], "state" => contact["state"] }
            payload.delete_if { |k, v| v.nil? }

  				  response = RestClient::Request.execute(
  						 :method => :post,
  						 :url => 'https://api.reply.io/v1/actions/addandpushtocampaign?apiKey='+ @campaign.reply_key,
  						 :payload => payload
  					)

            sleep(10)
  				  puts response.code.to_s
            if response.code == 200
                uploaded_contact = true
                @campaign.update_attribute(:peopleCount, @campaign.peopleCount + 1)
            end
            
            return uploaded_contact
  		rescue
  				  puts  "did not input into reply"
            return uploaded_contact
  		end
  end







end
