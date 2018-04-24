class ClientCompaniesController < ApplicationController

before_action :authenticate_user!

def update
    @user = User.find(current_user.id)
    @company = ClientCompany.find(@user.client_company_id)

    if @company.update_attributes(model_params)
      redirect_to users_path, :notice => "Account updated."
    else
      redirect_to users_path, :alert => "Unable to update account."
    end
 end


def edit
	@user = User.find(current_user.id)
    @company = @user.client_company_id

    @client_company = ClientCompany.find(@company)
    

end

private

def model_params
  params.require(:client_company).permit(:number_of_seats, :emails_to_use, :notable_clients, :products, :description)
end

end