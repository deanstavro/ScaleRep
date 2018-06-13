class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_only, :except => :home

  def index
    @users = User.all
  end

  # Action when user signs in
  def home   

    if user_signed_in?

      @user = find_user
      @client_company = find_company

      redirect_to client_companies_personas_path

      # Direct to personas if account is live
      #if account_live
        #redirect_to client_companies_personas_path
      #else
        # Direct to onboarding if account is not live
        #render 'home'
      #end
    
    else
      render 'homepage#index'
    end
    
  end

  # Update user action
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  # Destroy user account
  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to 'homepage#index', :notice => "Your account has been deleted"
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

  def find_user
    return User.find(current_user.id)
  end

  def find_company
    ClientCompany.find(@user.client_company_id)
  end

  def account_live
    return @client_company.account_live == true
  end

end
