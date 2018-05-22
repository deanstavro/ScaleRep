class CreateDemos < ActiveRecord::Migration[5.0]
  def change
    create_table :demos do |t|
      t.string :name
      t.string :email
      t.string :phone_number
      t.string :comments

      t.timestamps
    end
  end
end
