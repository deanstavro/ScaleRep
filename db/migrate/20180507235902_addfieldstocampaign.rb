class Addfieldstocampaign < ActiveRecord::Migration[5.0]
  def change
  	add_column :campaigns, :reply_key, :string
  end
end
