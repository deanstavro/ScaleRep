ActiveAdmin.register Campaign do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :reply_id, :reply_key, :persona, :user_notes, :industry, :campaign_start, :campaign_end, :client_company_id
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
form do |f|                         
  f.inputs "Admin Details" do
  	f.input :client_company     
    f.input :reply_id
    f.input :reply_key
    f.input :persona
    f.input :user_notes
    f.input :industry
    f.input :campaign_start
    f.input :campaign_end
end                               
  f.actions                         
end

end
