class ChangeLeadTable < ActiveRecord::Migration[5.0]

def change
    remove_column :leads, :large_potential_deal, :boolean
    remove_column :leads, :project_scope, :boolean
    remove_column :leads, :timeline, :boolean
    remove_column :leads, :qualified_lead, :boolean
    remove_column :leads, :potential_deal_size, :string
    add_column :leads, :expected_recurring_deal, :string
    add_column :leads, :expected_recurrence_period, :string
    add_column :leads, :potential_deal_size, :integer
    add_column :leads, :contract_sent, :string
    add_column :leads, :contract_amount, :integer
    add_column :leads, :deal_won, :string
    add_column :leads, :deal_size, :integer
    add_column :leads, :timeline, :string
    add_column :leads, :project_scope, :string
    add_column :leads, :email_handed_off_too, :string
    rename_column :leads, :description, :internal_notes
    rename_column :leads, :notes, :external_notes
  end

   
end
