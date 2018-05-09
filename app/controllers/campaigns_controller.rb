class CampaignsController < ApplicationController
	before_action :authenticate_user!
	require 'rest-client'
	require 'json'
	include Reply


	'''
	Index shows all the campaigns running for a client_company
	Campaigns are grabbed from reply.io using the reply keys
	Campaigns are grabbed from one or multiple reply.io systems using the key(s)
	'''
	def index
    	
    	@user = User.find(current_user.id)
  		@company = ClientCompany.find_by(id: @user.client_company_id)
    	@campaigns = Campaign.where("client_company_id =?", @company).order('created_at DESC')

    	# Call app/lib/reply.get_campaigns module to get all campaigns from reply.io
    	@campaign_array = get_campaigns(@company.replyio_keys)

    	#################
    	#TO DO
    	#For all campaigns in the @campaign_array
    		# Call the campaign metrics api using the correct api key to get campaign metrics
    		#Push the response into a hash
    		# save in a global variable for display in the index.html.erb
    	##################
    	
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


  			campaign_array = get_campaigns(@company.replyio_keys)
  			email_array = get_email_accounts(@company.replyio_keys)

  			puts "EMAIL ARRAY"
  			puts email_array


  			count_dict = Hash.new
    		for email in email_array
    			count_dict[email["emailAddress"]] = 0
    		end


    		for email in campaign_array
    			for reply_email in email_array
    				if email["emailAccount"] == reply_email["emailAddress"]

    					if count_dict[email["emailAccount"]]
    						count_dict[email["emailAccount"]] = count_dict[email["emailAccount"]] + 1
    					else
    						count_dict[email["emailAccount"]] = 1
    					end
    				end
    			end
    		end


    		puts "COUNT_DICT"
    		puts count_dict

    		
    		
    		current_value = 1000
    		current_email = ""
    		count_dict.each do |key, value|

    			if value < current_value
    				current_value = value
    				current_email = key
    			end
    		end

    		email_to_use = current_email

    		for email in email_array

    			if current_email == email["emailAddress"]
    				reply_key = email["key"]

    				break
    			end
    		end

    		puts email_to_use + "  " + current_value.to_s + "  " + reply_key + "  " + params[:campaign][:persona]



  			if @campaign.save

  				post_campaign = JSON.parse(post_campaign(reply_key, email_to_use, params[:campaign][:persona]))

  				puts post_campaign

				
  				redirect_to client_company_campaigns_path, :notice => "Campaign created"
  			else
  				redirect_to client_company_campaigns_path, :alert => "Campaign not valid and not updated"

  			end
  			


    	else
      		redirect_to client_company_campaigns_path, :alert => "Campaign not valid and not updated"

   		end
   	end





  	private

  	
  	

  	def campaign_params
  		params.require(:campaign).permit(:name, :persona, :user_notes)
  	end	


  






end
