class Addfieldstocampaigns < ActiveRecord::Migration[5.0]
  def change
  	add_column :campaigns, :reply_id, :string
  	remove_column :campaigns, :name, :string
  end
end
