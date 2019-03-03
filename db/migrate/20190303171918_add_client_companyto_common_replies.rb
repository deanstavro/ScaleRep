class AddClientCompanytoCommonReplies < ActiveRecord::Migration[5.0]
  def change
  	add_reference :common_replies, :client_company, foreign_key: true
  end
end
