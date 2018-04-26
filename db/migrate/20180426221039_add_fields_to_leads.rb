class AddFieldsToLeads < ActiveRecord::Migration[5.0]
  def change
  	remove_column :leads, :position, :string
  	add_column :leads, :title, :string
  	add_column :leads, :phone_type, :string
  	add_column :leads, :phone_number, :string
  	add_column :leads, :city, :string
  	add_column :leads, :state, :string
  	add_column :leads, :country, :string
  	add_column :leads, :linkedin, :string
  	add_column :leads, :campaign_name, :string
  	add_column :leads, :timezone, :string
  	add_column :leads, :address, :string
  	add_column :leads, :meeting_taken, :boolean, default: false
  end
end
