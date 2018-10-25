require 'restforce'

module Salesforce_Integration
  
    def authenticate(salesforce_object)
      @client = Restforce.new :username => salesforce_object.username,
                    :password       => salesforce_object.password,
                    :security_token => salesforce_object.security_token,
                    :client_id     => salesforce_object.app_key,
                    :client_secret  => salesforce_object.app_secret
      begin
        @client.authenticate!
        return @client
      rescue
        return 400
      end
    end



    def create_salesforce_lead(salesforce_object, lead)
      client = authenticate(salesforce_object)
      upload = true

      if client == 400
        puts "ERROR"
        return false
      end
        #Use create method to call

      if salesforce_object.check_dup_against_existing_contact_email_option
          contacts = client.search('FIND {test123@example.com} RETURNING Contact (Email)').map(&:Email)
          if !contacts.empty?
            upload = false
          end
      end

      if salesforce_object.check_dup_against_existing_account_domain_option
          accounts = client.search('FIND {www.eden.io} RETURNING Account (Domain)').map(&:Email)
          if !accounts.empty?
            upload = false
          end
      end


      if upload = true
        client.create!('Contact',FirstName: "test", LastName: "test",Email: "test123@example.com",LeadSource: "ScaleRep")
        return true
      else
        return false
      end

    end


    def update(salesforce_object, lead)
      @client.update(sf_object, parse_fields_map(fields_map, entity_hash))
    end


end

