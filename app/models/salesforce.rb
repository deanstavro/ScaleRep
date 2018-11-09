class Salesforce < ApplicationRecord

	belongs_to :client_company

	before_save :default_checks


    def default_checks
    	if self.salesforce_integration_authorized == false
    		self.salesforce_integration_on = false
    		self.upload_contacts_to_salesforce_option = false
    		self.check_dup_against_existing_contact_email_option = false
    		self.check_dup_against_existing_account_domain_option = false
    	elsif self.salesforce_integration_on == false
    		self.upload_contacts_to_salesforce_option = false
    		self.check_dup_against_existing_contact_email_option = false
    		self.check_dup_against_existing_account_domain_option = false
    	end
    end

    def self.from_omniauth(auth)
      where(auth.slice(:provider, :uid).permit!).first_or_initialize.tap do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.name = auth.info.name
        #user.oauth_token = auth.credentials.token
        #user.refresh_token = auth.credentials.refresh_token
        #user.instance_url = auth.credentials.instance_url
        user.save!
      end
    end


end
