ActiveAdmin.register Salesforce do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :api_version, :app_key, :app_secret, :client_company_id, :sync_email_touchpoints_option, :upload_contacts_to_salesforce_option, :check_dup_against_existing_contact_email_option, :check_dup_against_existing_account_domain_option, :salesforce_integration_on, :salesforce_integration_authorized, :blacklist_fields, :upload_accounts_to_salesforce_option, :instance_url, :oauth_token, :refresh_token
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end


end
