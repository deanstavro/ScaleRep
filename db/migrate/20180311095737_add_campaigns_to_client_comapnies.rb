class AddCampaignsToClientComapnies < ActiveRecord::Migration[5.0]
  def change
    add_reference :campaigns, :client_company, foreign_key: true
    add_reference :leads, :client_company, foreign_key: true
    add_reference :leads, :campaign, foreign_key: true
  end
end
