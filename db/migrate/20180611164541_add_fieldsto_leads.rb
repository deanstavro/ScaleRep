class AddFieldstoLeads < ActiveRecord::Migration[5.0]
  def change
  	add_column :leads, :company_name, :string
  	add_column :leads, :company_website, :string

  	add_reference :leads, :account, foreign_key: true
  end
end
