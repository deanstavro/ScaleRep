class AddEnumToCampaigns < ActiveRecord::Migration[5.0]
  def change
    add_column :campaigns, :campaign_type, :integer
  end
end
