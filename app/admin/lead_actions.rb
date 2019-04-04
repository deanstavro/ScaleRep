ActiveAdmin.register LeadAction do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :touchpoint_id, :lead_id, :client_company_id, :action, :emailopen_number, :first_time, :email_sent_time
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
remove_filter :lead
remove_filter :touchpoint

end
