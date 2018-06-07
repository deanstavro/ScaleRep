class CreateCampaignReplies < ActiveRecord::Migration[5.0]
  def change
    create_table :campaign_replies do |t|
      t.string :first_name
      t.string :last_name
      t.string :full_name
      t.string :last_conversation_subject
      t.string :last_conversation_summary
      t.integer :status
      t.string :company
      t.string :email
      t.text :notes
      t.string :reply_io_id
      t.string :reply_io_key

      
      t.date :follow_up_date


      t.timestamps
    end
    add_reference :campaign_replies, :client_company, foreign_key: true
    add_reference :campaign_replies, :lead, foreign_key: true

    drop_table :auto_replies

  end

end
