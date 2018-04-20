class LeadListController < ApplicationController
  def index
    @user = User.find(current_user.id)
  	puts @user

  	@company = ClientCompany.find_by(id: @user.client_company_id)
  	puts @company

    # grab reports and grab leads for every week for a report
    @leads = Lead.where("client_company_id =?", @company).order('date_sourced DESC')


    #airrecord work
    #authenticate
    Airrecord.api_key = "keyvWvtDSd5MDiIBZ"
    #grab view
    @discover_needs_opps= Opportunity.all(filter: '{lead_status} = "discover_needs"')
    @qualified_opps= Opportunity.all(filter: '{lead_status} = "qualified"')

  end

  def edit
  end
end


# create Opportunity class
class Opportunity < Airrecord::Table
  self.base_key = "appBop3EYUrma7W4E"
  self.table_name = "MOFU"
end
