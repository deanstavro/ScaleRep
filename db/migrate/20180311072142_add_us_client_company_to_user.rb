class AddUsClientCompanyToUser < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :client_company, foreign_key: true
  end
end
