class AddUniqueOpensDefault < ActiveRecord::Migration[5.0]
  def change
  	remove_column :campaigns, :uniqueOpens, :integer
    add_column :campaigns, :uniqueOpens, :integer, :default => 0
  end
end
