class CreateAdminService
  def call
    	user = User.find_or_create_by!(email: Rails.application.secrets.admin_email, client_company: Rails.application.secrets.admin_client_company ) do |user|
        user.password = Rails.application.secrets.admin_password
        user.password_confirmation = Rails.application.secrets.admin_password
      end
  end
end
