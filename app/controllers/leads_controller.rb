class LeadsController < ApplicationController
  before_action :authenticate_user!
  include Reply
  require 'will_paginate/array'

  def index
    @user = User.find(current_user.id)

    if @user.role == "scalerep"
      @meetings_set = Lead.where(status: "handed_off").order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)

      @follow_up   = CampaignReply.where("follow_up_date is not null").where(status: "interested").order(:follow_up_date)
      @no_follow_ups = CampaignReply.where(follow_up_date: [nil, ""]).where(status: "interested")
      @follow_ups = (@no_follow_ups + @follow_up).paginate(:page => params[:page], :per_page => 20)


      @auto_reply = CampaignReply.where("follow_up_date is not null").where(status: "auto_reply", pushed_to_reply_campaign: false).order(:follow_up_date)
      @no_auto_reply = CampaignReply.where(follow_up_date: [nil, ""]).where(status: "auto_reply", pushed_to_reply_campaign: false)
      @auto_replies = (@no_auto_reply + @auto_reply).paginate(:page => params[:page], :per_page => 20)

      @referral    = CampaignReply.where.not(referral_email: [nil, ""]).where(:status => ["referral", "auto_reply_referral"],  pushed_to_reply_campaign: false).order(:follow_up_date)
      @no_referral    = CampaignReply.where(referral_email: [nil, ""]).where(:status => ["referral", "auto_reply_referral"],  pushed_to_reply_campaign: false)
      @referrals    = (@no_referral + @referral).paginate(:page => params[:page], :per_page => 20)

      @blacklist    = Lead.where(:status => ["not_interested", "blacklist"]).order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)

    else
      @company = ClientCompany.find_by(id: @user.client_company_id)
      @accounts = Account.where(client_company_id: @company.id).paginate(:page => params[:page], :per_page => 20)

      # grab reports and grab leads for every week for a report
      @interested_leads = CampaignReply.where(client_company_id: @company.id, status: "interested").order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)
      @blacklist = Lead.where(client_company_id: @company.id, status: "blacklist").order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)
      @meetings_set = Lead.where(client_company_id: @company.id, status: "handed_off").order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)

      @current_table = params[:table_id]
    end
  end



  def import_to_campaign

    @user = User.find(current_user.id)
    @company = ClientCompany.find_by(id: @user.client_company_id)
    @leads = Lead.where(client_company: @company)

    persona = params[:persona]

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
          upload_message = Lead.import_to_campaign(params[:file], @company, @leads, params[:campaign], col)
          puts "Finished uploading. Redirecting!"
          flash[:notice] = upload_message
          redirect_to client_companies_campaigns_path(persona)
          else

            redirect_to client_companies_campaigns_path(persona), :flash => { :error => "The CSV is too large. Please upload a shorter CSV!" }
            return
          end


        else

          redirect_to client_companies_campaigns_path(persona), :flash => { :error => "The file was not uploaded. Please Upload a CSV!" }
          return

        end
    rescue
        redirect_to client_companies_campaigns_path(persona), :flash => { :error => "No file chosen. Please upload a CSV!" }
        return

    end
  end

  def import_blacklist

    @user = User.find(current_user.id)
    @company = ClientCompany.find_by(id: @user.client_company_id)
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
          upload_message = Lead.import_blacklist(params[:file], @company, @leads, params, col)
          puts "Finished uploading blacklist. Redirecting!"
          flash[:notice] = upload_message
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
    @reply = CampaignReply.where(:email => params[:email]).where(:client_company => @company).first

    #update attributes
    if params.has_key?(:followUpDate) and params[:followUpDate] != ""
      @reply.update_attribute(:follow_up_date, Date.strptime(params[:followUpDate], "%m/%d/%Y"))
    end

    @reply.update_attribute(:notes, params[:notes])
    @reply.update_attribute(:status, params[:status])

    #update params if they exist and added for referrals
    if params.has_key?(:referralName)
      @reply.update_attribute(:referral_name, params[:referralName])
    end
    if params.has_key?(:referralEmail)
      @reply.update_attribute(:referral_email, params[:referralEmail])
    end

    # if we move a reply to handed-off/opt-out/not-interested, update lead
    if ["do_not_contact", "opt_out"].include?(params[:status])
      @reply.lead.update_attribute(:status, "blacklist")
    elsif ["handed_off"].include?(params[:status])
      @reply.lead.update_attribute(:status, "handed_off")
    elsif ["interested"].include?(params[:status])
      @reply.lead.update_attribute(:status, "interested")
    elsif ['not_interested'].include?(params[:status])
      @reply.lead.update_attribute(:status, "not_interested")
    else # auto_reply, auto_reply_referral, etc
      @reply.lead.update_attribute(:status, "in_campaign")
    end


    if @reply.status == "referral" or @reply.status == "auto_reply_referral"

      #update reply
      unless (@reply.referral_email.nil? || @reply.referral_email=="") and (@reply.referral_name.nil? || @reply.referral_name == "") and @reply.full_name.nil?
                response = add_referral_contact(@company.referral_campaign_key,@company.referral_campaign_id, @reply)

                #update referral so that we don't display
                @reply.update_attribute(:pushed_to_reply_campaign, !@reply.pushed_to_reply_campaign)
              end


    end





    #redirect
    redirect_to leads_path

  end



  private



end
