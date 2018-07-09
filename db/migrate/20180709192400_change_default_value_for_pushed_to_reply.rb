class ChangeDefaultValueForPushedToReply < ActiveRecord::Migration[5.0]
  def change
    change_column :campaign_replies, :pushed_to_reply_campaign, :boolean, null: false, default: false
  end
end
