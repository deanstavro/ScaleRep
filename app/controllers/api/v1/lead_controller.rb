class Api::V1::LeadController < Api::V1::BaseController

    # CampaignsController - post campaigns to scalerep system
    # api/v1/all_metrics - POST campaign to scalerep system
    # Required Fields:

    def edit

    	@client_company = ClientCompany.find_by(api_key: params[:api_key])

    	puts @client_company.name
    	puts params["first_name"]
    	puts params["api_key"]
    	

  	end



  	private


end
