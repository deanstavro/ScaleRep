class RemoveUneededFieldsFromLeads < ActiveRecord::Migration[5.0]
  def change
  	remove_column :leads, :contract_amount, :integer
  	remove_column :leads, :contract_sent, :string
  	remove_column :leads, :decision_maker, :boolean
  	remove_column :leads, :email_in_contact_with, :string
  	remove_column :leads, :hunter_date, :datetime
  	remove_column :leads, :hunter_score, :integer
  	remove_column :leads, :internal_notes, :text
  	remove_column :leads, :meeting_taken, :boolean
  	remove_column :leads, :meeting_time, :datetime
  	remove_column :leads, :project_scope, :string
  	remove_column :leads, :timeline, :string
  	remove_column :leads, :email_handed_off_too, :string

  end
end
