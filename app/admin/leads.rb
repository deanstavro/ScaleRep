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

permit_params :client_company_id, :date_sourced, :campaign_id, :persona_id, :first_name, :last_name,  :email, :title, :phone_type, :phone_number,  :city, :state, :country, :linkedin, :timezone, :address, :full_name, :status, :account_id, :company_name, :company_website

remove_filter :account
remove_filter :campaign_replies
remove_filter :campaign
remove_filter :touchpoints
remove_filter :lead_actions
remove_filter :persona


index do
    selectable_column
    id_column

    column :first_name
    column :last_name
    column :full_name
    column :status
    column :email
    column :client_company
    column :persona
    column :campaign
    
    column :title
    column :account
    column :company_name
    column :company_website

    column :phone_type
    column :phone_number
    column :linkedin
    column :timezone
    column :address
    column :city
    column :state
    column :country

    column :date_sourced



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
    f.input :persona
    f.input :phone_type
    f.input :phone_number
    f.input :timezone
    f.input :address
    f.input :city
    f.input :state
    f.inputs do
        f.input :country, as: :select, collection: country_dropdown
    end

    f.input :date_sourced


  end
  f.actions
end

def country_dropdown
    ActionView::Helpers::FormOptionsHelper::COUNTRIES
  end


end
