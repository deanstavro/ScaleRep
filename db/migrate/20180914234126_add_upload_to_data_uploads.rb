class AddUploadToDataUploads < ActiveRecord::Migration[5.0]
  def change
  		add_column :data_uploads, :imported_to_campaigns, :boolean, default: false
  end
end
