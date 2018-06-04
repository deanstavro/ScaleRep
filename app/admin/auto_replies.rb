ActiveAdmin.register AutoReply do
#  member_action :comments do
#       @post = Post.find(params[:id]
#       @comments = @post.comments
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
 permit_params :first_name, :last_name, :follow_up_date, :lead_status, :lead_email, :campaign_id, :client_company_id
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
form do |f|
  f.inputs "Auto Replies" do
  	f.input :first_name
    f.input :last_name
    f.input :lead_status
    f.input :follow_up_date
    f.input :lead_email
    f.input :campaign
    f.input :client_company

end
  f.actions
end

end
