class AddFieldsToPersonas < ActiveRecord::Migration[5.0]
  def change
  	add_column :personas, :description, :string
  	add_column :personas, :special_instructions, :string
  end
end
