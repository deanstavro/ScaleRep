class RemoveFieldsFromPersonasAndCampaigns < ActiveRecord::Migration[5.0]
  def change
  	remove_column :personas, :special_instructions, :string
  	remove_column :campaigns, :user_notes, :string
  	remove_column :campaigns, :industry, :string
  	remove_column :campaigns, :personalized, :boolean
  	remove_column :campaigns, :campaign_type, :integer
  	remove_column :campaigns, :has_minimum_email_score, :boolean
  	remove_column :campaigns, :minimum_email_score, :integer
  end
end
