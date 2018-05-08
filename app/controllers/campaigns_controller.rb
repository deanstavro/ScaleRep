class CampaignsController < ApplicationController
	before_action :authenticate_user!
	require 'rest-client'
	require 'json'

	def index
    	@user = User.find(current_user.id)
  		@company = ClientCompany.find_by(id: @user.client_company_id)
    	@campaigns = Campaign.where("client_company_id =?", @company).order('created_at DESC')

    	keys = JSON.parse(@company.replyio_keys)

    	@reply_campaigns = []
    	for accounts in keys["accounts"]
    		@reply_campaigns << JSON.parse(get_campaigns(accounts[1]["key"]))
    	end

    	@campaign_array = []
    	for accounts in @reply_campaigns
    		for campaign in accounts
    			if campaign["isArchived"] == false
    				@campaign_array << campaign
    				puts "new"
    				puts campaign
    			end
    		end
    	end


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

  		'''
  		if @campaign.valid?

  			@campaign_array = []
    		for accounts in @reply_campaigns
    			for campaign in accounts
    				if campaign["isArchived"] == false
    					@campaign_array << campaign
    					puts "new"
    				puts campaign
    			end
    		end
    	end

  			response = get_emails(company_key)
  			pu
  			#### HERE, DETERMINE WHERE TO CREATE THIS and store KEY and EMAIL #######
  		'''
  			





  			if @campaign.save

				begin

					response = RestClient.post "https://api.reply.io/v2/campaigns?apiKey=EeLPuf3EUR3YvKxnatkDLg2", {"name": @campaign.persona, "settings": { "EmailsCountPerDay": 200, "daysToFinishProspect": 7, "daysFromLastProspectContact": 15, "emailSendingDelaySeconds": 55, "emailPriorityType": "Equally divided between", "disableOpensTracking": false, "repliesHandlingType": "Mark person as finished", "enableLinksTracking": false }, "steps": [{ "number": "1", "InMinutesCount": "25", "templates": [{ "body": "Hello World!", "subject": "Im here!"}]}]}.to_json, :content_type => "application/json"
					data_hash = JSON.parse(response)


					@campaign.update_attribute(:reply_id, data_hash["id"])
					@campaign.update_attribute(:reply_key, 'EeLPuf3EUR3YvKxnatkDLg2')

				rescue RestClient::ExceptionWithResponse => e


					puts e

				end

  				redirect_to client_company_campaigns_path, :notice => "Campaign created"
    		else
      			redirect_to client_company_campaigns_path, :alert => "Campaign not valid and not updated"

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


	def get_emails(company_key)
		begin
			response = RestClient::Request.execute(
            	:method => :get,
            	:url => 'https://api.reply.io/v1/emailAccounts?apiKey='+ company_key,
            )
        	return response
		rescue RestClient::ExceptionWithResponse => e
			return e
		end
	end






end
