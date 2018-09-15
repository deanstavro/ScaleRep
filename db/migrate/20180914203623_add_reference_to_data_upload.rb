class AddReferenceToDataUpload < ActiveRecord::Migration[5.0]
  def change
  	add_reference :data_uploads, :user, foreign_key: true
  end
end
