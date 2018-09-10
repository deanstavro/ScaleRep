class RemoveSomeFieldsFromDataUpload < ActiveRecord::Migration[5.0]
  def change
  	add_column :data_uploads, :imported, :jsonb
  	add_column :data_uploads, :duplicates, :jsonb
  	add_column :data_uploads, :not_imported, :jsonb
  	add_column :data_uploads, :empty_email, :jsonb
  end
end
