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
      @personas = Persona.all
  		@client_company = ClientCompany.find_by(id: @user.client_company_id)
      @company_personas = @client_company.personas
  		@campaign = @client_company.campaigns.build
  end




  	def create
    	@user = User.find(current_user.id)
  		@company = ClientCompany.find_by(id: @user.client_company_id)
      @campaign = @company.campaigns.build(campaign_params)
      @campaigns = Campaign.where("client_company_id =?", @company).order('created_at DESC')


      # Determine Whether to Create A persona
      if params[:create_persona].present?

        persona = Persona.create(name: params[:create_persona], client_company: @company)
        @campaign.persona = persona

      else
        persona = Persona.find_by(id: params[:persona_id].to_i)
        @campaign.persona = persona
      end

      # Get Array of all emails
  		email_array = get_email_accounts(@company.replyio_keys)
      count_dict = email_count(email_array, @campaigns)

    	puts "COUNT_DICT"
    	puts count_dict

    	email_to_use = choose_email(count_dict)

    	puts "EMAIL TO USE"
    	puts email_to_use

  		for email in email_array

  			if email_to_use == email["emailAddress"]
  				reply_key = email["key"]
          puts "REPLY KEYS"
          puts reply_key

  				break
  			end
  		end

  		puts email_to_use.to_s + "  " + reply_key
      @campaign[:emailAccount] = email_to_use.to_s


			if @campaign.save

				post_campaign = JSON.parse(post_campaign(reply_key, email_to_use, params[:campaign][:campaign_name]))
				puts "RESPONSE FROM POSTING CAMPIGN INTO REPLY"
				puts post_campaign

				redirect_to client_company_campaigns_path, :notice => "Campaign created"
			else
				redirect_to client_company_campaigns_path, :alert => "Campaign not valid and not updated"

			end


   	end





  	private




  	def campaign_params
      params.require(:campaign).permit(:persona_id, :user_notes, :create_persona, :campaign_name)
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
