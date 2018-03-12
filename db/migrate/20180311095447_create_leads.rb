class CreateLeads < ActiveRecord::Migration[5.0]
  def change
    create_table :leads do |t|
      t.string :name
      t.string :company
      t.string :position
      t.boolean :decision_maker
      t.boolean :timeline
      t.boolean :project_scope
      t.boolean :large_potential_deal
      t.text :description
      t.text :notes
      t.string :potential_deal_size
      t.string :email_in_contact_with
      t.string :industry
      t.datetime :date_sourced
      t.boolean :qualified_lead



      t.timestamps
    end
  end
end
