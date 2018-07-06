class RemoveAirtableKeysFromClientCompanies < ActiveRecord::Migration[5.0]
  def change
    remove_column :client_companies, :airtable_keys, :string
  end
end
