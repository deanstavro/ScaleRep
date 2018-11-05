class AddBlackistFieldsHashToSalesforce < ActiveRecord::Migration[5.0]
  def change
  	  	add_column :salesforces, :blacklist_fields, :jsonb, default: []

  end
end
