class Addfieldstocampaign < ActiveRecord::Migration[5.0]
  def change
  	add_column :campaigns, :reply_key, :string
  	add_column :client_companies, :account_manager, :string
  	add_column :leads, :company_description, :string
  	add_column :leads, :number_of_employees, :string

  	add_column :leads, :last_funding_type, :string
  	add_column :leads, :last_funding_date, :string
  	add_column :leads, :last_funding_amount, :string
  	add_column :leads, :total_funding_amount, :string
  	add_column :leads, :email_snippet, :string

  end
end
