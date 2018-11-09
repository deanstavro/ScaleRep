class AddFieldsToSalesForce < ActiveRecord::Migration[5.0]
  def change
  	  	 add_column :salesforces, :instance_url, :string
  	  	 add_column :salesforces, :oauth_token, :string
  	  	 add_column :salesforces, :refresh_token, :string
  end
end
