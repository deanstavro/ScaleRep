class CreateTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :templates do |t|
      t.string :title
      t.text :body
      t.references :client_company, foreign_key: true
      t.timestamps
    end
  end
end
