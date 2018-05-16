class GetCampaignsFromReplyJob < ApplicationJob
	queue_as :default

	def perform()
    puts "Pulling Reply Campaign Metrics for All Companies"

    # Loop through all companies
    ClientCompany.find_each do |company|
      company.campaigns.find_each do |campaign|
        puts campaign.name

        # Use Reply key and reply id to call campaign

        # Get the response


        # For each metric

        # Update the campaign in the local database
      end
    end


	end

end

