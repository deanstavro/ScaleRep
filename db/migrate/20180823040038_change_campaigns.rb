class ChangeCampaigns < ActiveRecord::Migration[5.0]
  def change

  	def change
  		remove_column :client_companies, :airtable_keys, :string
    	add_column :campaigns, :uniqueOpens, :integer, :default => 0

  	end

  end
end
