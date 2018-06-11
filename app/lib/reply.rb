# frozen_string_literal: true

require 'rest-client'
require 'json'

module Reply
  API_V1 = 'https://api.reply.io/v1'
  API_V2 = 'https://api.reply.io/v2'

  def v1_get_campaigns(key)
    keys = JSON.parse(key, symbolize_names: true)
    unparsed_campaigns = []
    keys[:accounts].each do |account|
      response = RestClient::Request.execute(
        method: :get, url: "#{API_V1}/campaigns?apiKey=#{account[:key]}"
      )
      campaigns = JSON.parse(response, symbolize_names: true)
      unparsed_campaigns << campaigns
    end
    unparsed_campaigns
  end

  

  def v1_get_campaign(id, key)

    response = RestClient::Request.execute(
      method: :get, url: "#{API_V1}/campaigns/"+id.to_s+"?apiKey="+key.to_s
    )
    JSON.parse(response, symbolize_names: true)
  end

  

  def get_campaigns(company_key)
    keys = JSON.parse(company_key, symbolize_names: true)
    unparsed_campaigns = []
    metrics = v1_get_campaigns(@company.replyio_keys)&.flatten

    for accounts in keys[:accounts]
      begin
        response = RestClient::Request.execute(
          method: :get,
          url: 'https://api.reply.io/v2/campaigns?apiKey=' + accounts[:key]
        )
        # add reply key to the response
        un = JSON.parse(response)
        for campaign in un
          campaign['key'] = accounts[:key]
        end
        unparsed_campaigns << un
      rescue RestClient::ExceptionWithResponse => e
        return e
      end
    end
    # Loop through response to grab campaigns
    campaign_arr = []
    for accounts in unparsed_campaigns
      for campaign in accounts
        # Dont grab any archived campaigns
        if campaign['isArchived'] == false
          campaign[:metrics] = metrics.find do |metric|
            metric[:id] == campaign['id']
          end
          campaign_arr << campaign
        end
      end
    end
    campaign_arr
  end





  def add_contact(reply_key, reply_id, contact)

    begin

        puts reply_key
        puts reply_id
        puts contact["lead_email"]
        puts contact["first_name"]
        puts contact ["last_name"]
        
        payload = { "campaignId": reply_id, "email": contact["lead_email"], "firstName": contact["first_name"], "lastName": contact["last_name"]}


        response = RestClient::Request.execute(
           :method => :post,
           :url => 'https://api.reply.io/v1/actions/addandpushtocampaign?apiKey='+ reply_key,
           :payload => payload

        )

        sleep(15)

        puts response
        return response

    rescue


        puts "did not input into reply"
        return "did not input into reply"

    end

  end






  def get_email_accounts(company_key)


      keys = JSON.parse(company_key)

      # Get the correct reply keys, and call API to retrieve
      email_accounts = []
      for accounts in keys["accounts"]

        begin
            response = RestClient::Request.execute(
              :method => :get,
              :url => "https://api.reply.io/v1/emailAccounts?apiKey="+ accounts["key"],
            )

            #add reply key to the response
            un = JSON.parse(response)
            for email in un
              email["key"] = accounts["key"]
            end


            email_accounts << un


        rescue RestClient::ExceptionWithResponse => e
            return e
        end
      end

      # Loop through response to grab campaigns
      email_arr = []
      for accounts in email_accounts
        for email in accounts
            email_arr << email

        end
      end

      return email_arr

  end





  def post_campaign(key, email_to_use, persona_name)


      begin

          payload = {"name": persona_name, "emailAccount": email_to_use, "settings": { "EmailsCountPerDay": 400, "daysToFinishProspect": 7, "daysFromLastProspectContact": 15, "emailSendingDelaySeconds": 240, "emailPriorityType": "Equally divided between", "disableOpensTracking": false, "repliesHandlingType": "Mark person as finished", "enableLinksTracking": false }, "steps": [{ "number": "1", "InMinutesCount": "25", "templates": [{ "body": "Hello World!", "subject": "Im here!"}]}]}.to_json
          response = RestClient.post "https://api.reply.io/v2/campaigns?apiKey="+key, payload, :content_type => "application/json"
          data_hash = JSON.parse(response)


          @campaign.update_attribute(:reply_id, data_hash["id"])
          @campaign.update_attribute(:reply_key, key)

          return response

      rescue RestClient::ExceptionWithResponse => e

          puts e
          return e
      end

  end



end