class AddReferralCampaignToClientCompany < ActiveRecord::Migration[5.0]
  def change
    add_column :client_companies, :referral_campaign_key, :string
    add_column :client_companies, :referral_campaign_id, :string
  end
end
