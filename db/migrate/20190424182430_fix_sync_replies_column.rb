class FixSyncRepliesColumn < ActiveRecord::Migration[5.0]
  def change
      rename_column :salesforces, :sync_replies, :sync_email_touchpoints_option
  end
end
