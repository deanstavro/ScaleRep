class CreateCampaigns < ActiveRecord::Migration[5.0]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.text :description
      t.string :email1
      t.string :email2
      t.string :industry
      t.datetime :campaign_start
      t.datetime :campaign_end


      t.timestamps
    end
  end
end
