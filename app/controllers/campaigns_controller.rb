class CampaignsController < ApplicationController
	before_action :authenticate_user!
	require 'rest-client'
	require 'json'
	include Reply

	def index
    	@user = get_user
      @client_company = get_company(@user)
      @persona = get_persona(params)

      if wrong_campaign(@persona, @client_company)
          flash[:notice] = "Campaign does not exist"
          redirect_to client_companies_personas_path
        return
      end

      @campaigns = get_campaign(@persona, @client_company)
     
  end



  def new
    	@user = get_user
      @persona_name = params[:persona_name]
      @persona_id = params[:persona_id]

  		@client_company = get_company(@user)
      @personas = @client_company.personas.find_by(id: params[:persona_id])
  		@campaign = @client_company.campaigns.build
  end




  def create
    	@user = get_user
  		@company = get_company(@user)
      @campaign = @company.campaigns.build(campaign_params)
      @campaigns = Campaign.where("client_company_id =?", @company).order('created_at DESC')


      persona = Persona.find_by(id: params[:subaction].to_i)
      @campaign.persona = persona

      # Get Array of all emails
  		email_array = get_email_accounts(@company.replyio_keys)
      count_dict = email_count(email_array, @campaigns)

    	puts "email count_dict"
    	puts count_dict

      # Choose correct email based on which email is running the least campaigns
    	email_to_use = choose_email(count_dict)

    	puts "email to use: "
    	puts email_to_use
  		
      # Find the correct keys for that email to upload the campaign to that email
      for email in email_array
  			if email_to_use == email["emailAddress"]
  				reply_key = email["key"]
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


				redirect_to client_companies_campaigns_path(persona), :notice => "Campaign created"
			else
				redirect_to client_companies_campaigns_path(persona), :notice => @campaign.errors.full_messages

			end


  end



  private


    def get_user
      return User.find(current_user.id)
    end

    def get_company(user)
      return ClientCompany.find_by(id: user.client_company_id)
    end

    def get_persona(params)
      return Persona.find_by(id: params[:format])
    end

    def get_campaign(persona, client_company)
      return persona.campaigns.where("client_company_id =?", client_company).order('created_at DESC')
    end

    def wrong_campaign(persona, company)

        begin
            if persona.client_company != company
              return true
            else
              return false
            end
        rescue
            puts "persona does not exist for that user"
            return true
        end
    end


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
