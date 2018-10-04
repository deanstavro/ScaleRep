class AddClientCompanyToTouchpoints < ActiveRecord::Migration[5.0]
  def change
  		add_reference :touchpoints, :client_company, foreign_key: true
  end
end
