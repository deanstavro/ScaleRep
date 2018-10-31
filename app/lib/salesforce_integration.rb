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
      puts "Starting Salesforce Lead Creation Process"
      client = authenticate(salesforce_object)
      upload = true

      if client == 400
        puts "ERROR"
        return false
      end
        #Use create method to call

      if salesforce_object.check_dup_against_existing_contact_email_option
          upload = lead_unique_against_salesforce_email(salesforce_object, lead)
      end

      puts upload.to_s

      #if upload and salesforce_object.check_dup_against_existing_account_domain_option
      #      upload = lead_unique_against_salesforce_account(salesforce_object, lead)
      #end

      puts upload.to_s

      if upload
        client.create!('Contact',FirstName: lead["first_name"], LastName: lead["last_name"],Email: lead["email"],LeadSource: "ScaleRep")
        return true
      else
        return false
      end

    end


    def update(salesforce_object, lead)
      @client.update(sf_object, parse_fields_map(fields_map, entity_hash))
    end


    protected

    def lead_unique_against_salesforce_email(salesforce_object, lead)
        client = authenticate(salesforce_object)
        if client != 400
          contacts = client.search('FIND {'+lead["email"]+'} RETURNING Contact (Email)').map(&:Email)
          if contacts.empty?
            return true
          else
            return false
          end
        end
    end


    def lead_unique_against_salesforce_account(salesforce_object, lead)
        client = authenticate(salesforce_object)

        accounts = client.search('FIND {'+lead["company_website"]+'} RETURNING Account (Domain)').map(&:Domain)
        if accounts.empty?
          return true
        else
          return false
        end
    end


end

