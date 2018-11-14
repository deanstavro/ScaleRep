class AddEmailPoolToCampaigns < ActiveRecord::Migration[5.0]
  def change
  		add_column :campaigns, :email_pool, :jsonb, default: []
  end
end
