class AddArchiveToCampaigns < ActiveRecord::Migration[5.0]
  def change
  	add_column :campaigns, :archive, :boolean, default: false
  	add_column :personas, :archive, :boolean, default: false

  end
end
