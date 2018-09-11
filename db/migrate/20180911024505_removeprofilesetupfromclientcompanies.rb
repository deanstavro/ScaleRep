class Removeprofilesetupfromclientcompanies < ActiveRecord::Migration[5.0]
  def change
  	remove_column :client_companies, :profile_setup, :boolean
  end
end
