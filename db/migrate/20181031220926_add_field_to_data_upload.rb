class AddFieldToDataUpload < ActiveRecord::Migration[5.0]
  def change
  	add_column :data_uploads, :external_crm_duplicates, :jsonb, default: []
  end
end
