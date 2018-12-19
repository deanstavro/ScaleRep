class ApplicationController < ActionController::Base
  protect_from_forgery preprend: true
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def find_current_user(id)
  	user = User.find(id)
  	return user
  end

  def is_scalerep_admin(user)
  	if user.role == "scalerep"
  		return true
  	else
  		return false
  	end
  end

  def is_non_admin_user(user)
  	if user.role == "scalerep"
  		return false
  	else
  		return true
  	end
  end

  def scalerep_director_client_company()
  	client_companies = ClientCompany.where("account_live = ?", true).pluck(:name)
  	return client_companies
  end

  def after_sign_out_path_for(resource_or_scope)
    "https://www.scalerep.com"
  end

end
