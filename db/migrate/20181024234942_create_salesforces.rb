class CreateSalesforces < ActiveRecord::Migration[5.0]
  def change
    create_table :salesforces do |t|
      t.string :api_version
      t.string :username
      t.string :password
      t.string :security_token
      t.string :app_key
      t.string :app_secret
      t.boolean :salesforce_integration_on, default: false
      t.boolean :salesforce_integration_authorized, default: false
      t.boolean :upload_contacts_to_salesforce_option, default: false
      t.boolean :check_dup_against_existing_contact_email_option, default: false
      t.boolean :check_dup_against_existing_account_domain_option, default: false
      t.references :client_company, foreign_key: true


      t.timestamps
    end
  end
end
