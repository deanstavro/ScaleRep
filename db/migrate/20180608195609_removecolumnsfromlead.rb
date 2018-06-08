class Removecolumnsfromlead < ActiveRecord::Migration[5.0]
  def change
  	remove_column :leads, :in_campaign, :boolean
  	remove_column :leads, :campaign_name, :string
  	remove_column :leads, :last_added_to_campaign_date, :date
  	remove_column :leads, :sent_to_reply, :boolean
  	
  end
end
