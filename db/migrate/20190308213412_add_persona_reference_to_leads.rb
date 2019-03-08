class AddPersonaReferenceToLeads < ActiveRecord::Migration[5.0]
  def change
  	add_reference :leads, :persona, foreign_key: true
  end
end
