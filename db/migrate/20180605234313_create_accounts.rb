class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|

    	## Database authenticatable
      t.string :name, required: true
      t.string :phone_number
      t.string :website, required: true, unique: true
      t.string :industry
      t.text :description
      t.text :internal_notes
      t.boolean :do_not_contact, default: false
      t.string :number_of_employees
      t.string :address
      t.string :city
      t.string :state
      t.string :country
      t.string :zipcode
      t.string :timezone
      t.string :last_funding_type
      t.string :last_funding_amount
      t.string :total_funding_raised
      t.string :last_funding_date

      t.timestamps
    end


    remove_column :leads, :company, :string
    remove_column :leads, :industry, :string
    remove_column :leads, :external_notes, :string
    remove_column :leads, :expected_recurring_deal, :string
    remove_column :leads, :expected_recurrence_period, :string
    remove_column :leads, :number_of_employees, :string
    remove_column :leads, :potential_deal_size, :string

    remove_column :leads, :last_funding_type, :string
    remove_column :leads, :last_funding_date, :string
    remove_column :leads, :last_funding_amount, :string
    remove_column :leads, :total_funding_amount, :string
    remove_column :leads, :company_domain, :string

    add_column :leads, :full_name, :string


  end



end
