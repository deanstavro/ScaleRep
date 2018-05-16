class GetCampaignsFromReplyJob < ApplicationJob
	queue_as :default

	def perform()
    puts "WE here"

    # Loop through all companies
    
    ClientCompany.find_each do |company|
      company.campaigns.find_each do |campaign|
        puts campaign.name
      end
    end




    
      # Loop through all the campaigns

    # For each campaign

      # Use Reply key and reply id to call campaign

      # Get the response


      # For each metric


        # Update the campaign in the local database


	end

end

