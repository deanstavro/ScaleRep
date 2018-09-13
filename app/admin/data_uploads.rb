ActiveAdmin.register DataUpload do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
permit_params :campaign, :client_company, :data, :count, :imported, :imported_count, :not_imported, :not_imported_count, :duplicates, :duplicates_count, :headers, :rules, :cleaned_data, :actions

	json_editor
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

index do
    selectable_column
    id_column

    column :campaign
    column :client_company
    column :count
    
    column :headers
    column :rules
    column :actions
    column :ignore_duplicates

    column :created_at
    column :updated_at

    actions

  end

form do |f|
    f.inputs do
      
      f.input :campaign
      f.input :client_company
      f.input :count
      f.input :headers
      f.input :actions
      f.input :rules, as: :json
      f.input :cleaned_data, as: :json
      f.input :data, as: :json
      f.input :imported, as: :json
      f.input :not_imported, as: :json
      f.input :duplicates, as: :json
      
    end

    f.actions
  end

end
