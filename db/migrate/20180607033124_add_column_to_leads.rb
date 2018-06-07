class AddColumnToLeads < ActiveRecord::Migration[5.0]
  def change
  	add_column :leads, :status, :integer
  	add_column :leads, :last_conversation_subject, :string
  	add_column :leads, :last_conversation_summary, :text
  end
end
