class CreateCommonReplies < ActiveRecord::Migration[5.0]
  def change
    create_table :common_replies do |t|
      t.string :name
      t.text :common_message
      t.text :reply_message

      t.timestamps
    end
  end
end
