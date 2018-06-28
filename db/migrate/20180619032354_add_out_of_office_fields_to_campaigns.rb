class AddOutOfOfficeFieldsToCampaigns < ActiveRecord::Migration[5.0]
  def change
  	add_column :client_companies, :auto_reply_campaign_id, :string
  	add_column :client_companies, :auto_reply_campaign_key, :string
  end
end
