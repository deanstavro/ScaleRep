class RemoveSomeFieldsFromDataUpload < ActiveRecord::Migration[5.0]
  def change
  	add_column :data_uploads, :imported, :jsonb, default: []
  	add_column :data_uploads, :duplicates, :jsonb, default: []
  	add_column :data_uploads, :not_imported, :jsonb, default: []
  end
end
