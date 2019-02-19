class AddSubjectLinetoTemplates < ActiveRecord::Migration[5.0]
  def change
  	add_column :templates, :subject, :text
  end
end
