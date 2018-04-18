ActiveAdmin.register ClientCompany do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :description, :company_domain, :company_notes
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


  end
  f.actions
end

end
