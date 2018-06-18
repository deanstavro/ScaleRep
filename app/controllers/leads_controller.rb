class LeadsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = User.find(current_user.id)
  	@company = ClientCompany.find_by(id: @user.client_company_id)
    @accounts = Account.where(client_company_id: @company.id).paginate(:page => params[:page], :per_page => 20)

    # grab reports and grab leads for every week for a report
    @interested_leads = Lead.where(client_company_id: @company.id, status: "interested").order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)
    @blacklist = Lead.where(client_company_id: @company.id, status: "blacklist").order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)
    @meetings_set = Lead.where(client_company_id: @company.id, status: "meeting_set").paginate(:page => params[:page], :per_page => 20)

    @current_table = params[:table_id]

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






  private



end
