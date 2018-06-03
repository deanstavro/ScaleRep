class ChangeCompanyInAutoreplyToBeReferenceToConpany < ActiveRecord::Migration[5.0]
  def change
    remove_column :auto_replies, :company, :string
    add_reference :auto_replies, :client_company, foreign_key: true
  end
end
