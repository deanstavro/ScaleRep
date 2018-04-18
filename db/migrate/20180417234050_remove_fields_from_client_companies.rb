class RemoveFieldsFromClientCompanies < ActiveRecord::Migration[5.0]
  def change
    remove_column :client_companies, :email1, :string
    remove_column :client_companies, :email2, :string
    remove_column :client_companies, :plan, :string
    remove_column :users, :name
  end


end
