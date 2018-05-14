class AddCampaignNameToCampaign < ActiveRecord::Migration[5.0]
  def change
    add_column :campaigns, :campaign_name, :string
  end
end
