class CreateAgentrails < ActiveRecord::Migration[5.0]
  def change
    create_table :agentrails do |t|
      t.string :s

      t.timestamps
    end
  end
end
