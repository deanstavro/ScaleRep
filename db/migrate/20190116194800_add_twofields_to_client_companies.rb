class AddTwofieldsToClientCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :client_companies, :monthlyContactProspectingCount, :integer
    add_column :client_companies, :monthlyContactEngagementCount, :integer
  end
end
