ActiveAdmin.register Lead do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :contract_sent, :deal_won, :deal_size, :expected_recurring_deal, :expected_recurrence_period, :internal_notes, :external_notes, :contract_amount, :email_handed_off_too, :client_company_id, :date_sourced, :campaign_id, :name, :company, :position, :decision_maker, :timeline, :project_scope, :description, :notes, :potential_deal_size, :email_in_contact_with, :industry
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

    f.input :client_company
    f.input :campaign
    f.input :date_sourced
    f.input :email_in_contact_with
    f.input :email_handed_off_too
    f.input :name
    f.input :company
    f.input :industry
    f.input :position
    f.input :decision_maker
    f.input :timeline
    f.input :project_scope
    f.input :potential_deal_size
    f.input :expected_recurring_deal
    f.input :expected_recurrence_period
    f.input :internal_notes
    f.input :external_notes
    f.input :contract_sent, :as => :select, :collection =>  [:yes, :no]
    f.input :contract_amount
    f.input :deal_won
    f.input :deal_size


  end
  f.actions
end


end
