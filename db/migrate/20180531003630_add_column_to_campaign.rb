class AddColumnToCampaign < ActiveRecord::Migration[5.0]
  def change
  	add_column :campaigns, :minimum_email_score, :integer
  	add_column :campaigns, :has_minimum_email_score, :boolean
  end
end
