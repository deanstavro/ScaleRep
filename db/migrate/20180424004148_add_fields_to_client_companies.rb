class AddFieldsToClientCompanies < ActiveRecord::Migration[5.0]
  def change

  	add_column :client_companies, :number_of_seats, :integer
    add_column :client_companies, :emails_to_use, :text
    add_column :client_companies, :products, :text
    add_column :client_companies, :notable_clients, :text
    add_column :client_companies, :profile_setup, :boolean

  end
end
