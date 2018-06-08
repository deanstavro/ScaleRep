class Removecolumnsfromleads < ActiveRecord::Migration[5.0]
  def change
  	remove_column :leads, :deal_won, :string
  	remove_column :leads, :deal_size, :integer
  	remove_column :leads, :meeting_set, :boolean
  	remove_column :leads, :email_snippet, :string
  	remove_column :leads, :company_description, :string
  	remove_column :leads, :last_conversation_subject, :string
  	remove_column :leads, :last_conversation_summary, :text
  end
end
