ActiveAdmin.register Touchpoint do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :lead_id, :campaign_id, :client_company_id, :channel, :sender_email, :email_subject, :email_body
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
remove_filter :lead
remove_filter :campaign
remove_filter :lead_actions

end
