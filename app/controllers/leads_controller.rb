class LeadsController < ApplicationController
  before_action :authenticate_user!
  include Reply

  def index
    if current_user.role == "scalerep"
      # Take leads who have set meetings to display in Handed-Off
      @meetings_set = Lead.where(:status => ["handed_off", "handed_off_with_questions", "sent_meeting_invite"]).order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)
      # Show interested folks who need follow up
      @follow_up   = CampaignReply.where("follow_up_date is not null").where(status: "interested").order(:follow_up_date)
      @no_follow_ups = CampaignReply.where(follow_up_date: [nil, ""]).where(status: "interested")
      @follow_ups = (@no_follow_ups + @follow_up).paginate(:page => params[:page], :per_page => 20)
      # Show auto reply referrals and referrals
      @auto_reply = CampaignReply.where("follow_up_date is not null").where(status: "auto_reply", pushed_to_reply_campaign: false).order(:follow_up_date)
      @no_auto_reply = CampaignReply.where(follow_up_date: [nil, ""]).where(status: "auto_reply", pushed_to_reply_campaign: false)
      @auto_replies = (@no_auto_reply + @auto_reply).paginate(:page => params[:page], :per_page => 20)
      # Show referrals
      @referral    = CampaignReply.where.not(referral_email: [nil, ""]).where(:status => ["referral", "auto_reply_referral"],  pushed_to_reply_campaign: false).order(:follow_up_date)
      @no_referral    = CampaignReply.where(referral_email: [nil, ""]).where(:status => ["referral", "auto_reply_referral"],  pushed_to_reply_campaign: false)
      @referrals    = (@no_referral + @referral).paginate(:page => params[:page], :per_page => 20)
      # Take blacklist and display (not_interested, blacklist) leads
      @blacklist    = Lead.where(:status => ["not_interested", "blacklist"]).order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)
    else
      @company = current_user.client_company
      @accounts = Account.where(client_company_id: @company.id).paginate(:page => params[:page], :per_page => 20)
      # grab reports and grab leads for every week for a report
      @interested_leads = CampaignReply.where(client_company_id: @company.id, status: "interested").order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)
      @blacklist = Lead.where(client_company_id: @company.id, status: "blacklist").order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)
      @meetings_set = Lead.where(client_company_id: @company.id).where(:status => ["handed_off", "handed_off_with_questions", "sent_meeting_invite"]).order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)
      @current_table = params[:table_id]
    end
  end


  def show
    @lead = Lead.find_by(id: params[:id])
    checkUserPrivileges(:back, 'You cannot access this Lead')
    lead_actions = @lead.lead_actions.where.not(action:['reply']).paginate(:page => params[:page], :per_page => 20)
    touchpoints = @lead.touchpoints.select("created_at","channel","email_subject", "email_body", "sender_email").order("created_at desc").paginate(:page => params[:page], :per_page => 20)
    replies = @lead.campaign_replies.select("created_at","last_conversation_subject", "last_conversation_summary").order("created_at desc").paginate(:page => params[:page], :per_page => 20)

    @lead_history = (lead_actions + touchpoints + replies).sort_by(&:created_at).reverse
    # sum counts of each type
    @reply_count = replies.count
    @lead_actions_count = lead_actions.count
    @touchpoints_count = touchpoints.count
  end


  #POST - save cleaned_data contacts and upload into reply
  def import_to_current_campaign
    puts params

    @data_object = DataUpload.find_by(id: params[:data_upload])
    persona = @data_object.campaign.persona
    LeadUploadJob.perform_later(@data_object)
    @data_object.update_attribute(:imported_to_campaigns, true)
    redirect_to client_companies_campaigns_path(persona), :flash => { :notice => "Contacts are being save and uploaded. Wait for task to finish!" }
  end


  # POST, Reclean data, and show STEP 3 page, the page rendered after rules and inputted data cleaned
  def update_lead_import

        @user = User.find(current_user.id)
        @data_upload = DataUpload.find_by(id: params[:data_upload])
        @cleaned_data_copy = @data_upload.cleaned_data
        @cleaned_data_count = @cleaned_data_copy.count
        @headers = @data_upload.data[0].keys
        @campaign = @data_upload.campaign
        @client_company = @campaign.client_company
        @per_page = params[:per_page].to_i

        if params[:page].empty?
          @page = 1
        else
          @page = params[:page].to_i
        end


        new_cleaned_hash = []
        row_array = []
        params_copy = params.dup.except(:controller,:action, :commit, :authenticity_token, :data_upload, :utf8, :page, :per_page)

        # If edits are being made on the second page and beyond, we must first copy the data

        lead_start = ((@page.to_i - 1)*@per_page.to_i) + 1
        lead_end = ((@page.to_i)*@per_page.to_i)
        puts "ON PAGE: " + @page.to_s
        puts "PER PAGE: " + @per_page.to_s
        puts "LEAD_START:" + lead_start.to_s
        puts "Lead end: " + lead_end.to_s

        if @page > 1
          #copy cleaned_data into new array up until page
          @cleaned_data_copy[0...lead_start-1].each do |clean_data|
              new_cleaned_hash << clean_data
          end
        end


        #puts params_copy
        previous_row = "0"
        params_copy.each do |key, value|

            row_column_array = key.split("_")
            row_index_string = row_column_array[0].to_s
            column_index_string = row_column_array[1].to_s

            #if row_index_string.to_i < lead_start

            if row_index_string == previous_row
              row_array << value
            else

              previous_row = row_index_string
              new_cleaned_hash_row = Hash[@headers.zip(row_array)]
              new_cleaned_hash << new_cleaned_hash_row
              row_array = []
              row_array << value
            end
        end

        # Add in last row
        new_cleaned_hash_row = Hash[@headers.zip(row_array)]
        new_cleaned_hash << new_cleaned_hash_row


        begin
          @cleaned_data_copy[lead_end..-1].each do |clean_data|
              new_cleaned_hash << clean_data
          end
        rescue
            puts "out of range"
        end


        @data_upload.update_attribute(:cleaned_data, new_cleaned_hash)

   redirect_to data_upload_path(:id => @data_upload.id), :flash => { :notice => "Your changes have been saved. Click '+ import to campaign' to add to the the list to the campaign!" }
   return
  end

  def import_blacklist

    @user = User.find(current_user.id)
    #@company = ClientCompany.find_by(id: @user.client_company_id)
    @leads = Lead.where(client_company: @company)
    col =  Lead.column_names
    # Column Names
    # id, decision_maker, internal_notes, email_in_contact_with, date_sourced
    # created_at, updated_at, client_company_id, campaign_id, contract_sent,
    # contract_amount, timeline, project_scope, email_handed_off_too, meeting_time,
    # email, first_name, last_name, hunter_score, hunter_date, title, phone_type,
    # phone_number, city, state, country, linkedin, timezone, address, meeting_taken,
    # full_name, status, company_name, company_website, account_id
    puts "THIS IS COL"
    puts col
    begin
        if (params[:file].content_type).to_s == 'text/csv'
          if (params[:file].size).to_i < 1000000

          puts "Starting upload method"
          AddBlacklistJob.perform_now(params[:file], @company, @leads, params, col)
          puts "Finished uploading blacklist. Redirecting!"
          flash[:notice] = "Uploading..."
          redirect_to :back
          else
            redirect_to :back, :flash => { :error => "Blacklist CSV is too large. Please upload a shorter CSV!" }
            return
          end
        else

          redirect_to :back, :flash => { :error => "Blacklist file was not uploaded. Please Upload a CSV!" }
          return
        end
    rescue
        redirect_to :back, :flash => { :error => "No blacklist file chosen. Please upload a CSV!" }
        return

    end
  end


  def update_reply_from_portal
    # used to update follow_up_date and notes
    # find the reply and update the lead
    @company = ClientCompany.find_by(id: params[:company_id])
    @reply = CampaignReply.find_by(id: params[:campaign_reply_id])
    #update attributes
    if params[:status] == "referral" or params[:status] == "auto_reply_referral"
        #update params if they exist and added for referrals
        @reply.update_attributes(:referral_name => params[:referralName], :referral_email => params[:referralEmail], :company => params[:company], :status => params[:status], :full_name => params[:full_name] )

        #update reply
        unless (@reply.referral_email.nil? or @reply.referral_email=="") or (@reply.referral_name.nil? or @reply.referral_name == "") or @reply.full_name.nil?
          response = add_referral_contact(@company.referral_campaign_key,@company.referral_campaign_id, @reply)
          puts "push referral reply response: " + response

          if response != "did not input into reply"
            @reply.update_attribute(:pushed_to_reply_campaign, !@reply.pushed_to_reply_campaign)
          end
        end
    end
    begin
      @reply.update_attribute(:follow_up_date, Date.strptime(params[:followUpDate], "%m/%d/%Y"))
    rescue
      @reply.update_attribute(:follow_up_date, "")
    end
    @reply.update_attribute(:notes, params[:notes])

    begin
      @reply.update_attribute(:company, params[:company])
    rescue
      @reply.update_attribute(:company, "")
    end
    @reply.update_attribute(:first_name, params[:first_name])
    @reply.update_attribute(:status, params[:status])


    begin
        # if we move a reply to handed-off/opt-out/not-interested, update lead
        if ["do_not_contact", "opt_out"].include?(params[:status])
          @reply.lead.update_attribute(:status, "blacklist")
        elsif ["handed_off"].include?(params[:status])
          @reply.lead.update_attributes(:status => "handed_off", :date_sourced => Date.today)
        elsif ["interested"].include?(params[:status])
          @reply.lead.update_attribute(:status => "interested")
        elsif ["not_interested"].include?(params[:status])
          @reply.lead.update_attribute(:status => "not_interested")
        elsif ["handed_off_with_questions"].include?(params[:status])
          @reply.lead.update_attributes(:status => "handed_off_with_questions", :date_sourced => Date.today)
        elsif ["sent_meeting_invite"].include?(params[:status])
          @reply.lead.update_attributes(:status => "sent_meeting_invite", :date_sourced => Date.today)
        else # auto_reply, auto_reply_referral, etc
          @reply.lead.update_attribute(:status => "in_campaign")
        end
    rescue
      puts "no associated lead with reply_campaign"
    end

    #redirect
    redirect_to leads_path
  end


  private

  def checkUserPrivileges(path, message)
    if !is_scalerep_admin && @lead.client_company != current_user.client_company
      redirect_to metrics_path, notice: message
    end
  end
end
