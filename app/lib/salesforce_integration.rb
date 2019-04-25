require 'restforce'
require 'Date'
module Salesforce_Integration
  protected

    # Authenticates Restforce Gem (Salesforce Client)
    # Returns @client or 400, and accepts salesforce db object
    def authenticate(salesforce_object)
      @client = Restforce.new :oauth_token => salesforce_object.oauth_token,
                    :instance_url       => salesforce_object.instance_url,
                    :client_id     => salesforce_object.app_key,
                    :client_secret  => salesforce_object.app_secret,
                    :refresh_token => salesforce_object.refresh_token,
                    :authentication_callback => Proc.new { |x| Rails.logger.debug x.to_s },
                    :api_version => salesforce_object.api_version
      begin
        @client.authenticate!
        puts "Salesforce Client Authenticated"
        return @client
      rescue
        puts "Salesforce Client Unable to Authenticate"
        return 400
      end
    end


    def upload_replies_to_salesforce(campaignReply, salesforce)
      #find Lead from object -- all CampaignReplies have an associated lead
      leadFromCampaignReply = Lead.find(campaignReply.lead.id)
      puts "finished leadFromCampaignReply - starting salesforceLead"

      #authenticate
      @client = authenticate(salesforce)

      #find
      salesforceLead = nil
      begin
        salesforceLead = @client.find('Lead', leadFromCampaignReply.email, 'Email')
      rescue
        puts "in rescue"
        salesforceLead = nil
      end

      if salesforceLead.present?
        # create email touch
        task = @client.create('Task', WhoId:salesforceLead.Id, Status: "Completed", Priority:"Normal", Subject: campaignReply.last_conversation_subject, Description: campaignReply.last_conversation_summary, ActivityDate: campaignReply.created_at.to_date)

        # if lead has been handed off, we need to update stats
        # only need to do this work in campaign replies
        puts "status is " + leadFromCampaignReply.status

        if ['handed_off','handed_off_with_questions','sent_meeting_invite'].include?leadFromCampaignReply.status
          puts "determined this was a handoff"
          @client.update('Lead', Id: salesforceLead.Id, Status: "Working")
        end

      else # else case
        #Create Lead
        puts campaignReply.lead.first_name, campaignReply.lead.last_name, campaignReply.lead.email
        # LEAD TODO: need a company name - how do we get this or put a placeholder?
        # lead = @client.create('Lead', FirstName: campaignReply.lead.first_name, LastName: campaignReply.lead.last_name, Email:campaignReply.lead.email, Account:campaignReply.lead.email)
        task = @client.create('Task', Status: "Open", Priority:"Normal", Subject: campaignReply.last_conversation_subject, Description: campaignReply.last_conversation_summary, ActivityDate: campaignReply.created_at.to_date)
        puts lead
      end

      puts "created this Task!"
      puts task
    end

    def upload_touchpoints_to_salesforce(touchpoint,salesforce)
      #find Lead from object -- all CampaignReplies have an associated lead
      leadFromTouchpoint= Lead.find(touchpoint.lead.id)
      puts "finished leadFromCampaignReply - starting salesforceLead"

      #authenticate
      @client = authenticate(salesforce)

      #find
      salesforceLead = nil

      begin
        salesforceLead = @client.find('Lead', leadFromTouchpoint.email, 'Email')
      rescue
        puts "in rescue"
        salesforceLead = nil
      end


      puts "found salesforceLead"
      puts salesforceLead

      if salesforceLead.present?
        # create email touch
        task = @client.create('Task', WhoId:salesforceLead.Id, Status: "Completed", Priority:"Normal", Subject: touchpoint.email_subject, Description: touchpoint.email_body, ActivityDate: touchpoint.created_at.to_date)

      else # else case
        lead = @client.create('Lead', FirstName: campaignReply.lead.first_name, LastName: campaignReply.lead.last_name, Email:campaignReply.lead.email)
        task = @client.create('Task', Status: "Open", Priority:"Normal", Subject: touchpoint.email_subject, Description: touchpoint.email_body, ActivityDate: touchpoint.created_at.to_date)
        puts 'created an open lead and an open task'

      end
      puts "created this Task!"
      puts task

    end

    # Creates Lead If Lead Does Not Exist (Fields: FirstName, LastName, Email, Title, LeadSource, Description)
    # Updates Lead if lead exists (updates LeadSource and Description)
    # Returns true if lead is created
    # Returns false if lead is updated
    def create_or_find_salesforce_lead(account_id, salesforce, lead, campaign)
      puts "Starting Salesforce Lead Creation Process"
      client = authenticate(salesforce)

      if client == 400
        puts "ERROR Authenticating. Returning"
        return false
      end

      upload_contacts = find_salesforce_contact_by_email(client, lead["email"])
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
      account_ids, account_search_term = find_salesforce_account_by_domain(client, salesforce, lead)

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
    def find_salesforce_contact_by_email(client, lead_email)
        copy_email = lead_email.dup

        if copy_email.include? "-"
          copy_email = copy_email.gsub!("-","\u2013")
        end

        contacts = client.search('FIND {'+copy_email+'} RETURNING Contact (Email)')
        return contacts.first.last
    end


    # Takes in a salesforce object, a salesforce client, and a lead to upload its account
    #
    # This first determines the search term by company website or by the end of the email
    # We then make a search call to salesforce, which returns an array of ids based on the search
    #
    # We return the account_ids array, and the search term
    def find_salesforce_account_by_domain(client, salesforce_object, lead)
      puts "Search for salesforce account"
      if lead["company_website"]
        # If company website exists, strip to host and use as search term
        com_website = lead["company_website"]

        if com_website.include? "//"
          lead_array = com_website.split("//").last
          com_website = lead_array
        end
        if com_website.include? "www."
          lead_array = com_website.split(".")
          lead_array.shift
          domain = lead_array.join(".")
          com_website = domain
        end

        account_search_term = com_website
      else
        # if company website doesn't exist, use email to find domain
        con_email = lead["email"].dup
        account_search_term = con_email.split("@").last
      end

      if account_search_term.include? "-"
          account_search_term.gsub!("-","\u2013")
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
