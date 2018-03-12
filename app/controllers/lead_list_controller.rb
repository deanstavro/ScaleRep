class LeadListController < ApplicationController
  def index
    @user = User.find(current_user.id)
  	puts @user

  	@company = ClientCompany.find_by(id: @user.client_company_id)
  	puts @company

    # grab reports and grab leads for every week for a report
    @qualified_leads = Lead.where("client_company_id =? AND qualified_lead = TRUE" , @company)
    @warm_leads = Lead.where("client_company_id =? AND qualified_lead = FALSE" , @company)

  end

  def edit
  end
end
