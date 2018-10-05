class CreateLeadActions < ActiveRecord::Migration[5.0]
  def change
    create_table :lead_actions do |t|
      t.integer :action
      t.string :email_open_number
      t.string :first_time
      t.references :touchpoint, foreign_key: true
      t.references :lead, foreign_key: true
      t.references :client_company, foreign_key: true

      t.timestamps
    end
  end
end
