class RemoveFieldsFromSalesforce < ActiveRecord::Migration[5.0]
  def change
  	remove_column :salesforces, :username, :string
  	remove_column :salesforces, :password, :string
  	remove_column :salesforces, :security_token, :string
  end
end
