class AddFieldsToCampaigns < ActiveRecord::Migration[5.0]
  def change
  	add_column :campaigns, :last_poll_from_reply, :string
  	add_column :campaigns, :emailAccount, :string
  	add_column :campaigns, :deliveriesCount, :integer
  	add_column :campaigns, :opensCount, :integer
  	add_column :campaigns, :repliesCount, :integer
  	add_column :campaigns, :bouncesCount, :integer

  	add_column :campaigns, :optOutsCount, :integer
  	add_column :campaigns, :outOfOfficeCount, :integer
  	add_column :campaigns, :peopleCount, :integer

  	add_column :campaigns, :peopleFinished, :integer
  	add_column :campaigns, :peopleActive, :integer
  	add_column :campaigns, :peoplePaused, :integer

    remove_column :campaigns, :name, :string

  end
end
