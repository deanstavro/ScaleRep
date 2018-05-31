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
     
  end



  def new
    	@user = User.find(current_user.id)
      @persona_name = params[:persona_name]
      @persona_id = params[:persona_id]

  		@client_company = ClientCompany.find_by(id: @user.client_company_id)
      @personas = @client_company.personas.find_by(id: params[:persona_id])
  		@campaign = @client_company.campaigns.build
  end




  	def create
    	@user = User.find(current_user.id)
  		@company = ClientCompany.find_by(id: @user.client_company_id)
      @campaign = @company.campaigns.build(campaign_params)
      @campaigns = Campaign.where("client_company_id =?", @company).order('created_at DESC')


      persona = Persona.find_by(id: params[:subaction].to_i)
      @campaign.persona = persona

      # Get Array of all emails
  		email_array = get_email_accounts(@company.replyio_keys)
      count_dict = email_count(email_array, @campaigns)

    	puts "COUNT_DICT"
    	puts count_dict

      # Choose correct email based on which email is running the least campaigns
    	email_to_use = choose_email(count_dict)

    	puts "EMAIL TO USE"
    	puts email_to_use
  		
      # Find the correct keys for that email to upload the campaign to that email
      for email in email_array

  			if email_to_use == email["emailAddress"]
  				reply_key = email["key"]
          puts "REPLY KEYS"
          puts reply_key

  				break
  			end
  		end

      # Add the email account we will use to the local campaign object
  		puts email_to_use.to_s + "  " + reply_key
      @campaign[:emailAccount] = email_to_use.to_s


      # Save the campaign locally
			if @campaign.save

        # If the campaign saves, post the campaign to reply
				post_campaign = JSON.parse(post_campaign(reply_key, email_to_use, params[:campaign][:campaign_name]))


				redirect_to client_company_campaigns_path, :notice => "Campaign created"
			else
				redirect_to client_company_campaigns_path, :notice => @campaign.errors.full_messages

			end


   	end





  	private




  	def campaign_params
      params.require(:campaign).permit(:persona_id, :user_notes, :create_persona, :campaign_name, :minimum_email_score, :has_minimum_email_score)
  	end




  	def email_count(email_array, campaign_array)

  		count_dic = Hash.new
		for email in email_array
			count_dic[email["emailAddress"]] = 0
		end


		for campaign in campaign_array
			for reply_email in email_array

				if campaign.emailAccount == reply_email["emailAddress"]

					if count_dic[campaign.emailAccount]
						count_dic[campaign.emailAccount] = count_dic[campaign.emailAccount] + 1
					else
						count_dic[campaign.emailAccount] = 1
					end
				end
			end
		end

		return count_dic

  	end


  	def choose_email(count_dict= count_dict)

  		current_value = 1000
    		current_email = ""
    		count_dict.each do |key, value|

    			if value < current_value
    				current_value = value
    				current_email = key
    			end
    		end

    		return current_email

  	end









end
