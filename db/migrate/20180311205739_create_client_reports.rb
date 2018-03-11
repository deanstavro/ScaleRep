class CreateClientReports < ActiveRecord::Migration[5.0]
  def change
    create_table :client_reports do |t|
      t.datetime :week_of
      t.integer :warm_generated_leads
      t.integer :qualified_leads
      t.text :report
      t.string :potential_deal_sizes

      t.timestamps
    end
  end
end
