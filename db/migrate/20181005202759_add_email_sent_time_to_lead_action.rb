class AddEmailSentTimeToLeadAction < ActiveRecord::Migration[5.0]
  def change
  	add_column :lead_actions, :email_sent_time, :datetime
  end
end
