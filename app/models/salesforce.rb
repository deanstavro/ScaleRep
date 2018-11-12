class Salesforce < ApplicationRecord
	belongs_to :client_company
	before_save :default_checks

    def default_checks
        # Set Default Restforce API Version
        self.api_version ||= '39.0'

        #If Salesforce is Not Authorized, All Salesforce Options Should Be Turned Off, And Integration Should be Off
    	if self.salesforce_integration_authorized == false
    		self.salesforce_integration_on = false
    		self.upload_contacts_to_salesforce_option = false
            self.upload_accounts_to_salesforce_option = false
    		self.check_dup_against_existing_contact_email_option = false
    		self.check_dup_against_existing_account_domain_option = false
        # If Salesforce Is Authorized But Not On, Turn All Salesforce Options Off
    	elsif self.salesforce_integration_on == false
            self.upload_accounts_to_salesforce_option = false
    		self.upload_contacts_to_salesforce_option = false
    		self.check_dup_against_existing_contact_email_option = false
    		self.check_dup_against_existing_account_domain_option = false
    	end
    end


end
