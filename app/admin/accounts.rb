ActiveAdmin.register Account do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :name, :website, :status, :industry, :description, :internal_notes, :do_not_contact,  :number_of_employees, :address, :city, :state, :country, :zipcode, :timezone, :last_funding_type, :last_funding_amount, :total_funding_raised, :last_funding_date, :client_company_id
#
# or
#

# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form do |f|
  f.inputs "Accounts" do


	f.input :name
    f.input :website
    f.input :status
    f.input :phone_number
    f.input :client_company
    f.input :industry
    f.input :description
    f.input :internal_notes
    f.input :do_not_contact
    f.input :number_of_employees
    f.input :address
    f.input :city
    f.input :state
    f.inputs do 
        f.input :country, as: :select, collection: country_dropdown
	end

    f.input :zipcode
    f.input :timezone
    f.input :last_funding_type
    f.input :last_funding_amount
    f.input :total_funding_raised
    f.input :last_funding_date
 

	end
	f.actions


end

end
