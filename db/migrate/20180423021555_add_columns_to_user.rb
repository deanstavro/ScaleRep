class AddColumnsToUser < ActiveRecord::Migration[5.0]
  def change
  	add_column :client_companies, :airtable_keys, :text
    add_column :client_companies, :replyio_keys, :text
    add_column :users, :api_key, :string
    add_column :client_companies, :api_key, :string
  end
end
