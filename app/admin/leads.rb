ActiveAdmin.register Lead do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :contract_sent, :deal_won, :deal_size, :expected_recurring_deal, :expected_recurrence_period, :internal_notes, :external_notes, :contract_amount, :email_handed_off_too, :client_company_id, :date_sourced, :campaign_id, :first_name, :last_name, :company, :decision_maker, :timeline, :project_scope, :potential_deal_size, :email_in_contact_with, :industry, :meeting_set, :meeting_time, :meeting_taken, :company_domain, :email, :hunter_date, :hunter_score, :title, :phone_type, :phone_number, :address, :city, :state, :country, :linkedin, :campaign_name, :timezone

index do
    selectable_column
    id_column

    column :first_name
    column :last_name
    column :client_company
    column :email
    column :title
    column :campaign
    column :campaign_name
    column :hunter_date
    column :hunter_score
    column :phone_type
    column :phone_number
    column :timezone
    column :address
    column :city
    column :state
    column :country
    column :company
    column :company_domain
    column :industry
    column :internal_notes
    column :external_notes
    column :linkedin


    column :email_in_contact_with
    column :email_handed_off_too
    column :meeting_set
    column :meeting_time
    column :meeting_taken
    column :expected_recurring_deal
    column :expected_recurrence_period
    column :potential_deal_size
    column :project_scope
    column :timeline
    column :date_sourced
    column :decision_maker
    column :contract_sent
    column :contract_amount
    column :deal_won
    column :deal_size





    actions
  end

#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
form do |f|
  f.inputs "Lead Details" do

    f.input :first_name
    f.input :last_name
    f.input :client_company
    f.input :email
    f.input :title
    f.input :campaign
    f.input :campaign_name
    f.input :hunter_date
    f.input :hunter_score
    f.input :phone_type
    f.input :phone_number
    f.input :timezone
    f.input :address
    f.input :city
    f.input :state
    f.inputs do 
        f.input :country, as: :select, collection: country_dropdown
    end
    f.input :company
    f.input :company_domain
    f.input :industry
    f.input :internal_notes
    f.input :external_notes

    f.input :linkedin


    f.input :email_in_contact_with
    f.input :email_handed_off_too
    f.input :meeting_set
    f.input :meeting_time
    f.input :meeting_taken
    f.input :expected_recurring_deal
    f.input :expected_recurrence_period
    f.input :potential_deal_size
    f.input :project_scope
    f.input :timeline
    f.input :date_sourced
    f.input :decision_maker
    f.input :contract_sent
    f.input :contract_amount
    f.input :deal_won
    f.input :deal_size
    
    


  end
  f.actions
end

def country_dropdown 
    ActionView::Helpers::FormOptionsHelper::COUNTRIES
  end 


end
