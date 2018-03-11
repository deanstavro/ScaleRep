class ClientReportsController < ApplicationController
  def index
  	@user = User.find(current_user.id)
  	puts @user
  	@company = ClientCompany.find_by(id: @user.client_company_id)
  	puts @company
  	#@user = User.find_by(:id)
  	@reports = ClientReport.where("client_company_id =?" , @company)

  end
end
