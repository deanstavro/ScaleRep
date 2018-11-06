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

    

    # Creates Lead If Lead Does Not Exist (Fields: FirstName, LastName, Email, Title, LeadSource, Description)
    # Updates Lead if lead exists (updates LeadSource and Description)
    # Returns true if lead is created
    # Returns false if lead is updated
    def create_or_find_salesforce_lead(account_id, salesforce, lead, campaign)
      puts "Starting Salesforce Lead Creation Process"
      client = authenticate(salesforce)

      if client == 400
        puts "ERROR"
        return false
      end

      upload_contacts = salesforce_contact_by_email(client, salesforce, lead)
      persona_name = campaign.persona.name

      if upload_contacts.empty?
        field_dict = createSalesforceHash(lead, persona_name)

        # Account for creating a contact with and without an account
        if account_id == "nil"
          client.create!('Contact', FirstName: field_dict["FirstName"] , LastName: field_dict["LastName"] , Email: field_dict["Email"], Title: field_dict["Title"] , Description: field_dict["Description"] , LeadSource: field_dict["LeadSource"]  )
        else
          client.create!('Contact', AccountId: account_id, FirstName: field_dict["FirstName"] , LastName: field_dict["LastName"] , Email: field_dict["Email"], Title: field_dict["Title"] , Description: field_dict["Description"] , LeadSource: field_dict["LeadSource"]  )
        end

        return true
      else
        #Update salesforce contacts --> upload = salesforce contacts
        for contact in upload_contacts
          puts contact.attributes.to_s.split("/").last.split('"').first
          contact_salesforce_id = contact.attributes.to_s.split("/").last.split('"').first
          client.update!('Contact', Id: contact_salesforce_id, Description: persona_name , LeadSource: "ScaleRep" )
        end
        return false
      end

    end



    # Returns Account Id of the Salesforce Account Created Or Found
    def create_of_find_salesforce_account(salesforce, lead, campaign)
      puts "Finding or creating salesforce account"
      client = authenticate(salesforce)

      if client == 400
        puts "ERROR"
        return false
      end
      account_ids, account_search_term = salesforce_search_account(client, salesforce, lead)
      
      if account_ids.empty?
        puts "ACCOUNT ID EMPTY"

        if !lead["company_name"]
          lead["company_name"] = account_search_term
        end
        # Create Account if it does not exist
        account_id = client.create!('Account', Website: account_search_term, Name: lead["company_name"]  )
        sleep(1)
        puts "CREATED ID: " + account_id.to_s
        return account_id
      else
        # Get Account ID of the first
        account_id = account_ids.first.Id
        puts "ACCOUNT ID EXISTS: " + account_id.to_s
      end
      
      return account_id
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

    # Returns contacts if contacts exist
    def salesforce_contact_by_email(client, salesforce_object, lead)
        contacts = client.search('FIND {'+lead["email"]+'} RETURNING Contact (Email)')
        return contacts
    end


    # Takes in a salesforce object, a salesforce client, and a lead to upload its account
    #
    # This first determines the search term by company website or by the end of the email
    # We then make a search call to salesforce, which returns an array of ids based on the search
    #
    # We return the account_ids array, and the search term
    def salesforce_search_account(client, salesforce_object, lead)
      puts "Search for salesforce account"
      if lead["company_website"]

        if lead["company_website"].include? "//"
          lead_array = lead["company_website"].split("//").last
          lead["company_website"] = lead_array
        end

        if lead["company_website"].include? "www."
          lead_array = lead["company_website"].split(".")
          lead_array.shift
          domain = lead_array.join(".")
          lead["company_website"] = domain
        end

        account_search_term = lead["company_website"]

      else
        account_search_term = lead["email"].split("@").last
      end
      puts "ACCOUNT SEARCH TERM: " + account_search_term
      account_ids = client.search('FIND {' + account_search_term + '} RETURNING Account (Id)')

      begin
        puts "ID: " + account_ids.first.Id.to_s
      rescue
        account_ids = []
      end

      return account_ids, account_search_term
    end


end

