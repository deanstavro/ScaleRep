class CreateTouchpoints < ActiveRecord::Migration[5.0]
  def change
    create_table :touchpoints do |t|
      t.integer :channel
      t.string :sender_email
      t.string :email_subject
      t.string :email_body
      t.references :lead, foreign_key: true
      t.references :campaign, foreign_key: true

      t.timestamps
    end
  end
end
