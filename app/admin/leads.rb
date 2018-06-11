ActiveAdmin.register Lead do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

permit_params :contract_sent, :internal_notes, :contract_amount, :email_handed_off_too, :client_company_id, :date_sourced, :campaign_id, :first_name, :last_name, :decision_maker, :timeline, :project_scope,  :email_in_contact_with,  :email, :meeting_set, :meeting_time, :hunter_date, :hunter_score, :title, :phone_type, :phone_number,  :city, :state, :country, :linkedin, :timezone, :address, :meeting_taken, :company_description, :full_name, :status, :account_id, :company_name, :company_website

index do
    selectable_column
    id_column

    column :first_name
    column :last_name
    column :full_name
    column :status
    column :client_company
    column :account
    column :email
    column :title
    column :account
    column :company_name
    column :company_website

    column :campaign

    column :hunter_date
    column :hunter_score

    column :phone_type
    column :phone_number
    column :linkedin
    column :timezone
    column :address
    column :city
    column :state
    column :country

    column :internal_notes
    column :email_in_contact_with
    column :email_handed_off_too
    column :meeting_time
    column :meeting_taken
    column :project_scope
    column :timeline
    column :date_sourced
    column :decision_maker
    column :contract_sent
    column :contract_amount



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
    f.input :full_name
    f.input :status
    f.input :client_company 
    f.input :email
    f.input :title
    f.input :linkedin
    f.input :account
    f.input :company_name
    f.input :company_website
    
    f.input :campaign
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
    f.input :internal_notes
    f.input :email_in_contact_with
    f.input :email_handed_off_too
    f.input :meeting_time
    f.input :meeting_taken
    f.input :project_scope
    f.input :timeline
    f.input :date_sourced
    f.input :decision_maker
    f.input :contract_sent
    f.input :contract_amount


  end
  f.actions
end

def country_dropdown 
    ActionView::Helpers::FormOptionsHelper::COUNTRIES
  end 


end
