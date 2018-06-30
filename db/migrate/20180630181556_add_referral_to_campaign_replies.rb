class AddReferralToCampaignReplies < ActiveRecord::Migration[5.0]
  def change
    add_column :campaign_replies, :referral_name, :string
    add_column :campaign_replies, :referral_email, :string
  end
end
