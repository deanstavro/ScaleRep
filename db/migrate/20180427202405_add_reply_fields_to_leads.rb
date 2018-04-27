class AddReplyFieldsToLeads < ActiveRecord::Migration[5.0]
  

  def change
  	add_column :leads, :in_campaign, :boolean, default: false
  	add_column :leads,  :last_added_to_campaign_date, :date
  end
end
