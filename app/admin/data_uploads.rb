ActiveAdmin.register DataUpload do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
permit_params :campaign, :client_company, :data, :count, :imported, :imported_count, :not_imported, :not_imported_count, :duplicates, :duplicates_count

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
    
    column :imported_count
    column :not_imported_count
    column :duplicates_count

    column :created_at
    column :updated_at

    actions

  end

form do |f|
    f.inputs do
      
      f.input :campaign
      f.input :client_company
      f.input :count
      f.input :data, as: :json
      f.input :imported
      f.input :imported_count
      f.input :not_imported
      f.input :not_imported_count
      f.input :duplicates
      f.input :duplicates_count

    end

    f.actions
  end

end
