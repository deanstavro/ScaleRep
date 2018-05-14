class AddPersonaToCampaign < ActiveRecord::Migration[5.0]
  def change
    add_reference :campaigns, :persona, foreign_key: true
  end
end
