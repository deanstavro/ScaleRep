class AddfieldstodataUploads < ActiveRecord::Migration[5.0]
  def change
  	add_column :data_uploads, :ignore_duplicates, :boolean, default: false
  	add_column :data_uploads, :headers, :string
  	add_column :data_uploads, :actions, :integer
  	add_column :data_uploads, :cleaned_data, :jsonb, default: []
  	add_column :data_uploads, :rules, :jsonb, default: []
  end
end
