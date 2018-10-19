class CampaignsController < ApplicationController
  	before_action :authenticate_user!
  	require 'rest-client'
  	require 'json'
  	include Reply

    # Display all campaigns for a particular persona
  	def index
  			@user = find_current_user(current_user.id)
        @client_company = @user.client_company
  			@persona = Persona.find_by(id: params[:format])
        
        #If user accesses a campaign of another user, return flash
  			if is_non_admin_user(@user) and wrong_persona(@persona, @client_company)
            flash[:notice] = "Campaign does not exist"
            redirect_to client_companies_personas_path
            return
  			end

        @campaigns = @persona.campaigns.all.order('created_at DESC')
  			@current = @campaigns.where("archive =?", false).paginate(:page => params[:page], :per_page => 20)
  	    @archive = @campaigns.where("archive =?", true).paginate(:page => params[:page], :per_page => 20)

    end

    #Display individual controller
    def show
        @user = find_current_user(current_user.id)
        @campaign = Campaign.find_by(id: params[:id])

        #If user accesses a campaign of another user, return flash
        if is_non_admin_user(@user) and wrong_campaign(@campaign, @user)
            redirect_to root_path, :flash => { :error => "Campaign does not exist" }
            return
        end

    end


    # Create new campaign
    def new
      	@user = find_current_user(current_user.id)
        # Used to land on this page in index
        @persona_id = params[:persona_id]
        @persona = Persona.find_by(id: @persona_id)
        @client_company_for_campaign = @persona.client_company
    		@campaign = @client_company_for_campaign.campaigns.build    
    end


    # POST - create new campaign, call reply
    def create

    		@company = ClientCompany.find_by(name: params[:campaign][:client_company])
        @campaign = @company.campaigns.build(campaign_params)
        @campaigns = @company.campaigns.all.order('created_at DESC')
        persona = Persona.find_by(id: params[:subaction].to_i)
        @campaign.persona = persona

        # Get Array of all emails
    		email_array = get_email_accounts(@company.replyio_keys)
        count_dict = email_count(email_array, @campaigns)

      	puts "email count_dict: "+ count_dict
        # Choose correct email based on which email is running the least campaigns
      	email_to_use = choose_email(count_dict)
      	puts "email to use: " + email_to_use

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


    # Archive Campaigns
  	def archive
        @campaign = Campaign.find_by(id: params[:format])
        @campaign.update_attribute(:archive, !@campaign.archive)
        redirect_to client_companies_campaigns_path(:format => @campaign.persona.id)
    end


    private


    # Check if regular user is trying to access campaign show page with id that doesn't belong to them.
    def wrong_persona(persona, company)
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


    def wrong_campaign(campaign, user)
      puts "HEY"
      begin
          if campaign.client_company != user.client_company
              puts "YUP"
              return true
          else
              puts "NOPE"
              return false
          end
      rescue
            puts "persona does not exist for that user"
            return true
      end
    end


    # Secure campaign params
  	def campaign_params
        params.require(:campaign).permit(:persona_id, :contactLimit, :user_notes, :create_persona, :campaign_name, :minimum_email_score, :has_minimum_email_score)
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


  	def choose_email(count_dict)
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
