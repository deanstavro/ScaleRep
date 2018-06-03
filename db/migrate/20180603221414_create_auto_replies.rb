class CreateAutoReplies < ActiveRecord::Migration[5.0]
  def change
    create_table :auto_replies do |t|
      t.string :company
      t.string :reply_id
      t.string :campaign_id
      t.string :first_name
      t.string :last_name
      t.date :follow_up_date
      t.string :lead_status
      t.string :lead_email

      t.timestamps
    end
  end
end
