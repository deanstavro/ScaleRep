class AddReportsToClientCompanies < ActiveRecord::Migration[5.0]
  def change
  	add_reference :client_reports, :client_company, foreign_key: true
  end
end
