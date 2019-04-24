class AddRepliesToSalesforces < ActiveRecord::Migration[5.0]
  def change
    add_column :salesforces, :sync_replies, :boolean
  end
end
