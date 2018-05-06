class ChangeNamesTiFields < ActiveRecord::Migration[5.0]
  def change
  	remove_column :campaigns, :description, :string
  	remove_column :campaigns, :email1, :string
  	remove_column :campaigns, :email2, :string
  	add_column :campaigns, :user_notes, :string
  	add_column :campaigns, :persona, :string
  end
end
