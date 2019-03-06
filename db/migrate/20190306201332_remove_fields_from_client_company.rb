class RemoveFieldsFromClientCompany < ActiveRecord::Migration[5.0]
  def change
  	remove_column :client_companies, :monthlyContactProspectingCount, :integer
  	remove_column :client_companies, :description, :text
  	remove_column :client_companies, :company_notes, :text
  	remove_column :client_companies, :products, :text
  	remove_column :client_companies, :emails_to_use, :text
  	remove_column :client_companies, :number_of_seats, :integer
  	remove_column :client_companies, :notable_clients, :text
  end
end
