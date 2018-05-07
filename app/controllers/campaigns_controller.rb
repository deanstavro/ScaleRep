class CampaignsController < ApplicationController
	before_action :authenticate_user!
	require 'rest-client'

	def index
    	@user = User.find(current_user.id)
  		@company = ClientCompany.find_by(id: @user.client_company_id)
    	@campaigns = Campaign.where("client_company_id =?", @company).order('created_at DESC')

    	keys = JSON.parse(@company.replyio_keys)
    	api_key = keys["api_key"]["key"]

    	@reply_campaigns = JSON.parse(get_campaigns(api_key))
    	create_campaign(@reply_campaigns, @campaigns)




  	end


  	def new
    	@user = User.find(current_user.id)

  		@client_company = ClientCompany.find_by(id: @user.client_company_id)
  		@campaign = @client_company.campaigns.build

  	end


  	def create
    	@user = User.find(current_user.id)
  		@company = ClientCompany.find_by(id: @user.client_company_id)

  		@campaign = @company.campaigns.build(campaign_params)

  		if @campaign.valid?
  			

  			if @campaign.save



  				objArray = JSON.parse(@company.replyio_keys)

      			api_key = objArray["api_key"]["key"]
	      			puts "API_KEY"
	      			puts api_key
	      			puts "CAMPAIGNNN"
	      			puts @campaign.name

				payload = { "name": "test 10",
        		"steps": [
   					{
   					"templates": [
     					{ 
     						"body": "Hello World!",
     						"subject": "I'm here!"
     					}
    					]
   					}
  				]
				}


				begin

					puts "LEY"
					puts api_key
					puts payload
					response = RestClient::Request.execute(
						:method => :post,
						:url => 'https://api.reply.io/v2/campaigns?apiKey='+ api_key,
						:payload => payload

						)

					puts response

				rescue RestClient::ExceptionWithResponse => e


					puts e

				end





  				#AddCampaignToReplyJob.perform_later(@campaign,@company.replyio_keys)
  				redirect_to client_company_campaigns_path, :notice => "Campaign created"
    		else
      			redirect_to client_company_campaigns_path, :alert => "Campaign not updated"

    		end
    	else
    		redirect_to client_company_campaigns_path, :alert => "Campaign not updated. Campaign not valid"
    	end




  	end





  	private

  	
  	

  	def campaign_params
  		params.require(:campaign).permit(:name, :persona, :user_notes)
  	end	


  	

  	def get_campaigns(company_key)
		begin
			response = RestClient::Request.execute(
            	:method => :get,
            	:url => 'https://api.reply.io/v2/campaigns?apiKey='+ company_key,
            )
        	return response
		rescue RestClient::ExceptionWithResponse => e
			return e
		end
	end



	def create_campaign(reply_campaigns, scalerep_campaigns)

		reply_campaigns.each do |reply_campaign|
			match = false
			scalerep_campaigns.each do |scalerep_campaign|
				if reply_campaign.id == scalerep_campaign.reply_id
					match = true

				end

				if match == false


					#create campaign

				







		if campaign.id


	end



end
