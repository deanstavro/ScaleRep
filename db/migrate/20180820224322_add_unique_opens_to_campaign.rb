class AddUniqueOpensToCampaign < ActiveRecord::Migration[5.0]
  def change
    add_column :campaigns, :uniqueOpens, :integer
  end
end
