class RemovePersonaFromCampaign < ActiveRecord::Migration[5.0]
  def change
    remove_column :campaigns, :persona, :string
  end
end
