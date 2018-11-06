class AddFieldToSalesForce < ActiveRecord::Migration[5.0]
  def change
  	  	 add_column :salesforces, :upload_accounts_to_salesforce_option, :boolean, default: false
  end
end
