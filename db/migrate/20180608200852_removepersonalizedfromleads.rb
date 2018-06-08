class Removepersonalizedfromleads < ActiveRecord::Migration[5.0]
  def change
  	remove_column :leads, :personalized, :boolean
  end
end
