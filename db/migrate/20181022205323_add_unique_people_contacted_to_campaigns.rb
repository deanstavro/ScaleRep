class AddUniquePeopleContactedToCampaigns < ActiveRecord::Migration[5.0]
  def change
  	add_column :campaigns, :uniquePeopleContacted, :integer
  end
end
