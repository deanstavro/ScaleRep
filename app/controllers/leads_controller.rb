class LeadsController < ApplicationController
before_action :authenticate_user!

  def index
    @user = User.find(current_user.id)
  	@company = ClientCompany.find_by(id: @user.client_company_id)

    # grab reports and grab leads for every week for a report
    @leads = Lead.where("client_company_id =?", @company).order('date_sourced DESC')


    #airrecord work
    #authenticate
    airtable = @company.airtable_keys

    airtable_dic = eval(airtable)
    puts airtable_dic["AIRTABLE"]

    table = Airrecord.table(airtable_dic["AIRTABLE"],airtable_dic["MOFU"],"MOFU")
    
    #grab view
    @pending_opps = table.all(filter: '{lead_status} = "discover_needs"', sort: {follow_up_date: "desc"})
    @qualified_opps = table.all(filter: '{lead_status} = "qualified"', sort: {follow_up_date: "desc"})
    @warm_opps = table.all(filter: '{lead_status} = "warm_lead"', sort: {follow_up_date: "desc"})

  end


  def import_to_campaign

    @user = User.find(current_user.id)
    @company = ClientCompany.find_by(id: @user.client_company_id)
    @leads = Lead.where(client_company: @company)

    col =  Lead.column_names


    begin
        if (params[:file].content_type).to_s == 'text/csv'
          if (params[:file].size).to_i < 1000000

          puts "HI"
          upload_message = Lead.import_to_campaign(params[:file], @company, @leads, params[:campaign], col)
          puts "HELLO"
          flash[:notice] = upload_message
          redirect_to client_company_campaigns_path(@company)
          else
            redirect_to client_company_campaigns_path(@company), :flash => { :error => "The CSV is too large. Please upload a shorter CSV!" }
          end

        else

          redirect_to client_company_campaigns_path(@company), :flash => { :error => "The file was not uploaded. Please Upload a CSV!" }

        end
    rescue
        redirect_to client_company_campaigns_path(@company), :flash => { :error => "No file chosen. Please upload a CSV!" }

    end
  end






  private



end
