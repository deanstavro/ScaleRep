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
            redirecemat_to client_companies_personas_path
            return
  			end

        @campaigns = @persona.campaigns.all.order('created_at DESC')
  			@current = @campaigns.where("archive =?", false).paginate(:page => params[:page], :per_page => 20)
  	    @archive = @campaigns.where("archive =?", true).paginate(:page => params[:page], :per_page => 20)
        @people_count = 0
        @emails_delivered = 0
        @emails_unique_opened = 0
        @emails_reply = 0
        @total_opens = 0
        @campaigns.each do |campaign|
            array = [campaign.peopleCount, campaign.deliveriesCount, campaign.repliesCount, campaign.uniqueOpens, campaign.opensCount]
            @people_count += array[0].to_i
            @emails_delivered += array[1].to_i
            @emails_reply += array[2].to_i
            @emails_unique_opened +=array[3].to_i
            @total_opens +=array[4].to_i
        end
    end

    #Display individual controller
    def show
        @user = find_current_user(current_user.id)
        @campaign = Campaign.find_by(id: params[:id])

        # execute reply api
        # TODO: move this to a job
        sequence = get_sequence(@campaign)

        # go through and format necessary inforation
        @sequence_array = []
        for count in 0..sequence.length-1 do
          step = {
            'number'  => sequence[count][:number].to_i,
            'day'     => sequence[count][:inMinutesCount]/60/24.to_i,
            'subject' => sequence[count][:templates][0][:subject],
            'body'    => sequence[count][:templates][0][:body]
          }
          @sequence_array.push(step)
       end

        #If user accesses a campaign of another user, return flash
        if is_non_admin_user(@user) and wrong_campaign(@campaign, @user)
            redirect_to root_path, :flash => { :error => "Campaign does not exist" }
            return
        end
    end


    # GET - Create new campaign
    def new
      	@user = find_current_user(current_user.id)
        @persona_id = params[:persona_id]
        @persona = Persona.find_by(id: @persona_id)
        @client_company_for_campaign = @persona.client_company
    		@campaign = @client_company_for_campaign.campaigns.build

        email_array = get_email_accounts(@client_company_for_campaign.replyio_keys)
        @emails = email_array.map{|x| x["emailAddress"]}
        @emails.unshift(Campaign.defaultCampaignChoice)

    end


    # POST - create new campaign, call reply
    def create
    		@company = ClientCompany.find_by(name: params[:campaign][:client_company])
        @campaign = @company.campaigns.build(campaign_params)
        @campaigns = @company.campaigns.all.order('created_at DESC')
        persona = Persona.find_by(id: params[:subaction].to_i)
        @campaign.persona = persona
        params[:campaign][:email_pool] = params[:campaign][:email_pool].reject { |c| c.empty? }
        email_array = get_email_accounts(@company.replyio_keys)

        if params[:campaign][:email_pool].include? Campaign.defaultCampaignChoice
          puts "Determining best email to use for campaign"
          count_dict = count_campaigns_per_email(email_array, @campaigns)
          @campaign[:emailAccount] = count_dict.key(count_dict.values.min)
        else
          puts "Choosing user inputted emails for campaigns"
          email_hash = Hash[params[:campaign][:email_pool].map {|key, | [key, 0]}]
          @campaign[:emailAccount] = email_hash.first.first
          email_hash[@campaign[:emailAccount]] = 1
          @campaign[:email_pool] = email_hash
        end

        # Find the correct keys for that email to upload the campaign to that email
        reply_key = get_reply_key_for_campaign(@campaign[:emailAccount], email_array)
        puts @campaign[:emailAccount].to_s + "  " + reply_key.to_s
        # Save the campaign locally
  			if @campaign.valid?
          # If the campaign saves, post the campaign to reply
  				post_campaign = JSON.parse(post_campaign(@campaign, reply_key, @campaign[:emailAccount]))
          @campaign.save
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


    # Secure campaign params
  	def campaign_params
        params.require(:campaign).permit(:persona_id, :contactLimit, :user_notes, :create_persona, :campaign_name, :minimum_email_score, :has_minimum_email_score, :email_pool)
  	end

    def get_sequence(campaign)
      response = RestClient.get(
        "https://api.reply.io/v2/campaigns/#{campaign.reply_id}/steps",
        {:'X-Api-Key' => "#{campaign.reply_key}"}
      )

      response = JSON.parse(response, symbolize_names: true)
    end


    # Check if regular user is trying to access persona show page with id that doesn't belong to them.
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

    # Check if regular user is trying to access campaign show page with id that doesn't belong to them.
    def wrong_campaign(campaign, user)
      begin
          if campaign.client_company != user.client_company
              return true
          else
              return false
          end
      rescue
            puts "persona does not exist for that user"
            return true
      end
    end


end
