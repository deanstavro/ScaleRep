class CreateDataUploads < ActiveRecord::Migration[5.0]
  def change
    create_table :data_uploads do |t|
      t.jsonb :data
      t.references :campaign
      t.references :client_company, foreign_key: true
      t.integer :count

      t.timestamps
    end
  end
end
