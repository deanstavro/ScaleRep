class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_only, :except => :home

  def index
    @users = User.all
  end

  
  def home   


    if user_signed_in?

      @user = User.find(current_user.id)
      @company = @user.client_company_id
      @client_company = ClientCompany.find(@company)

 
      if @client_company.account_live == true
        redirect_to personas_path
      else
        render 'home'

      end
    else
      render 'home'
    end
    
    
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to users_path, :notice => "User deleted."
  end

  private

  def admin_only
    unless current_user.admin?
      redirect_to root_path, :alert => "Access denied."
    end
  end

  def secure_params
    params.require(:user).permit(:role)
  end

end
