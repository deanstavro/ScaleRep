class AddStatusToAccount < ActiveRecord::Migration[5.0]
  def change
  	add_column :accounts, :status, :integer
  	add_reference :accounts, :client_company, foreign_key: true
  end
end
