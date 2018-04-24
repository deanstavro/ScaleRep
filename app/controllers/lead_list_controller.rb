class LeadListController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @user = User.find(current_user.id)
  	puts @user

  	@company = ClientCompany.find_by(id: @user.client_company_id)
  	puts @company

    # grab reports and grab leads for every week for a report
    @leads = Lead.where("client_company_id =?", @company).order('date_sourced DESC')


    #airrecord work
    #authenticate
    airtable = @company.airtable_keys

    airtable_dic = eval(airtable)
    puts airtable_dic["AIRTABLE"]


    table = Airrecord.table(airtable_dic["AIRTABLE"],airtable_dic["MOFU"],"MOFU")
    #grab view
    @pending_opps= table.all(filter: '{lead_status} = "discover_needs"')
    @qualified_opps= table.all(filter: '{lead_status} = "qualified"')

  end

  def edit
  end
end
