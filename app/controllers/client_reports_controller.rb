class ClientReportsController < ApplicationController
  before_action :authenticate_user!
  def index
  	@user = User.find(current_user.id)
  	@company = ClientCompany.find_by(id: @user.client_company_id)


    # grab reports and grab leads for every week for a report
  	@reports = ClientReport.where("client_company_id =?" , @company).order('week_of DESC')
    @leads = Lead.where("client_company_id =? " , @company)

  end
end
