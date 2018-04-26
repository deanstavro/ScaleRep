class AddMeetingSetToLeads < ActiveRecord::Migration[5.0]
  def change
  	add_column :leads, :meeting_set, :boolean, default: false
  	add_column :leads, :meeting_time, :datetime
  	add_column :leads, :email, :string
  	add_column :leads, :company_domain, :string

  	remove_column :leads, :name, :string
  	add_column :leads, :first_name, :string
  	add_column :leads, :last_name, :string
  	add_column :leads, :hunter_score, :integer
  	add_column :leads, :hunter_date, :datetime

  end
end
