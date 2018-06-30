class AddColumnToCampaignReplies < ActiveRecord::Migration[5.0]
  def change
    add_column :campaign_replies, :note, :string
  end
end
