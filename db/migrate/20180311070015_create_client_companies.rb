class CreateClientCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :client_companies do |t|
      t.string :name
      t.text :description
      t.string :email1
      t.string :email2
      t.integer :plan
      t.text :company_notes
      t.string :company_domain

      t.timestamps
    end
  end
end
