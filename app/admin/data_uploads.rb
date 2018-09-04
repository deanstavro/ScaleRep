ActiveAdmin.register DataUpload do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
permit_params :campaign, :client_company, :data, :count

	json_editor
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

form do |f|
    f.inputs do
      
      f.input :campaign
      f.input :client_company
      f.input :count
      f.input :data, as: :json
    end

    f.actions
  end

end
