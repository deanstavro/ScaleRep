class AddClientDirectorNotesToClientCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :client_companies, :clientDirectorNotes, :text
  end
end
