ActiveAdmin.register Lead do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :qualified_lead, :client_company_id, :date_sourced, :campaign_id, :name, :company, :position, :decision_maker, :timeline, :project_scope, :large_potential_deal, :description, :notes, :potential_deal_size, :email_in_contact_with, :industry
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
form do |f|
  f.inputs "Admin Details" do
    f.input :qualified_lead
    f.input :client_company
    f.input :campaign
    f.input :date_sourced
    f.input :name
    f.input :company
    f.input :position
    f.input :decision_maker
    f.input :timeline
    f.input :project_scope
    f.input :large_potential_deal
    f.input :description
    f.input :notes
    f.input :potential_deal_size
    f.input :email_in_contact_with
    f.input :industry


  end
  f.actions
end


end
