ActiveAdmin.register ClientCompany do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :description, :company_domain, :company_notes, :replyio_keys, :airtable_keys, :api_key, :number_of_seats, :email_to_use, :products, :notable_clients, :profile_setup
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form do |f|
  f.inputs "Client Company Details" do

    f.input :name
    f.input :company_domain
    f.input :description
    f.input :company_notes
    f.input :replyio_keys
    f.input :airtable_keys
    f.input :number_of_seats
    f.input :email_to_use
    f.input :products
    f.input :notable_clients
    f.input :profile_setup


  end
  f.actions
end

end
