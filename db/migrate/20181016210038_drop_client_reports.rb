class DropClientReports < ActiveRecord::Migration[5.0]
  def change
  	drop_table :client_reports
  end
end
