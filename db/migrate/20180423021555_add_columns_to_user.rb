class AddColumnsToUser < ActiveRecord::Migration[5.0]
  def change
  	add_column :client_companies, :airtable_keys, :text
    add_column :client_companies, :replyio_keys, :text
  end
end
