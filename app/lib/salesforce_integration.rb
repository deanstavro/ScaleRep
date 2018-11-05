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

    

    def create_salesforce_lead(salesforce_object, lead, campaign)
      puts "Starting Salesforce Lead Creation Process"
      client = authenticate(salesforce_object)
      upload = true

      if client == 400
        puts "ERROR"
        return false
      end

      if salesforce_object.check_dup_against_existing_contact_email_option
          upload = lead_unique_against_salesforce_email(salesforce_object, lead)
      end

      #if upload and salesforce_object.check_dup_against_existing_account_domain_option
      #      upload = lead_unique_against_salesforce_account(salesforce_object, lead)
      #end

      if upload
        persona_name = campaign.persona.name
        field_dict = createSalesforceHash(lead, persona_name)
        client.create!('Contact', FirstName: field_dict["FirstName"] , LastName: field_dict["LastName"] , Email: field_dict["Email"], Title: field_dict["Title"] , Description: field_dict["Description"] , LeadSource: field_dict["LeadSource"] )
        return true
      else
        return false
      end

    end


    def update(salesforce_object, lead)
      @client.update(sf_object, parse_fields_map(fields_map, entity_hash))
    end


    protected

    def createSalesforceHash(lead, persona)
        field_dict = Hash.new
        
        if lead["first_name"]
          field_dict["FirstName"] = lead["first_name"]
        end

        if lead["last_name"]
          field_dict["LastName"] = lead["last_name"]
        else
          field_dict["LastName"] = 'n/a'
        end

        if lead["email"]
          field_dict["Email"] = lead["email"]
        end

        if lead["title"]
          field_dict["Title"] = lead["title"]
        else
          field_dict["Title"] = "n/a"
        end

        field_dict["LeadSource"] = "ScaleRep"
        field_dict["Description"] = persona

        return field_dict
    end

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

