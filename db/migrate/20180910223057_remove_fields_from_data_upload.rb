class RemoveFieldsFromDataUpload < ActiveRecord::Migration[5.0]
  def change
  	remove_column :data_uploads, :imported, :jsonb
  	remove_column :data_uploads, :duplicates, :jsonb
  	remove_column :data_uploads, :not_imported, :jsonb
  	remove_column :data_uploads, :empty_email, :jsonb
  end
end
