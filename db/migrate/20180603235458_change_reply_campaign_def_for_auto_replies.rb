class ChangeReplyCampaignDefForAutoReplies < ActiveRecord::Migration[5.0]
  def change
    remove_column :auto_replies, :reply_id, :string
    remove_column :auto_replies, :campaign_id, :string
    add_reference :auto_replies, :campaign, foreign_key: true

  end
end
