class AddFieldstoDataUploads < ActiveRecord::Migration[5.0]
  def change
  	add_column :data_uploads, :imported, :jsonb
  	add_column :data_uploads, :not_imported, :jsonb
  	add_column :data_uploads, :duplicates, :jsonb
  	add_column :data_uploads, :imported_count, :integer
  	add_column :data_uploads, :duplicates_count, :integer
  	add_column :data_uploads, :not_imported_count, :integer

  end
end
