class AddContactLimitToCampaigns < ActiveRecord::Migration[5.0]
  def change
  	add_column :campaigns, :contactLimit, :integer
  end
end
