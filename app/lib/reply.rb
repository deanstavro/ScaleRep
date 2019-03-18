# frozen_string_literal: true
require 'rest-client'
require 'json'

module Reply
  protected


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

  def remove_contact(reply_key, contact_email)
    begin
        puts contact_email
        payload = {"email": contact_email}

        response = RestClient::Request.execute(
           :method => :post,
           :url => 'https://api.reply.io/v1/actions/removepersonfromallcampaigns?apiKey='+ reply_key,
           :payload => payload
        )

        sleep(5)
        puts response
        return response

    rescue
        puts "did not remove from reply"
        return "did not input into reply"
    end
  end

  def add_contact(reply_key, reply_id, contact)
    begin
        puts contact["email"]

        #check if contact exists. If so, pushtocampaign. If not, addandpushtocampaign
        # do this through nested begin/rescue
        response = nil
        begin

          contact_exists_response = RestClient::Request.execute(
             :method => :get,
             :url => 'https://api.reply.io/v1/people?email='+ contact["email"]+ "&apiKey=" + reply_key
          )

          puts "contact exists -- adding to reply campaign"

          payload = { "campaignId": reply_id, "email": contact["email"]}

          response = RestClient::Request.execute(
             :method => :post,
             :url => 'https://api.reply.io/v1/actions/pushtocampaign?apiKey='+ reply_key,
             :payload => payload
          )
        rescue
          puts "contact does not exist, so creating new one"

          payload = { "campaignId": reply_id, "email": contact["email"], "firstName": contact["first_name"], "lastName": contact["last_name"]}

          response = RestClient::Request.execute(
             :method => :post,
             :url => 'https://api.reply.io/v1/actions/addandpushtocampaign?apiKey='+ reply_key,
             :payload => payload
          )
        end

        sleep(5)

        return response
    rescue

        puts "did not input into reply"
        return "did not input into reply"

    end

  end




  def add_referral_contact(reply_key, reply_id, contact)
    begin

        #check if contact exists. If so, pushtocampaign. If not, addandpushtocampaign
        # do this through nested begin/rescue
        response = nil
        begin

          response = RestClient::Request.execute(
             :method => :get,
             :url => 'https://api.reply.io/v1/people?email='+ contact.referral_email+ "&apiKey=" + reply_key
          )

          puts "contact exists -- do nothing because we will already be emailng them"

        rescue
          puts "contact does not exist, so creating new one to put into referral campaign"


          payload = { "campaignId": reply_id, "email": contact.referral_email, "firstName": contact.referral_name, "title": contact.full_name }

          response = RestClient::Request.execute(
             :method => :post,
             :url => 'https://api.reply.io/v1/actions/addandpushtocampaign?apiKey='+ reply_key,
             :payload => payload
          )

        end

        return response
    rescue
        puts "did not input into reply"
        return "did not input into reply"
    end
  end




  # Accepts client_Company Key
  # Returns array of email_objects from Reply.io
  # This call Reply for each reply account, and returns all email account object in an array
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
            #add reply key to each the response and push to one array
            un = JSON.parse(response)
            for email in un
              email["key"] = accounts["key"]
              email_accounts << email
            end
        rescue RestClient::ExceptionWithResponse => e
            return e
        end
      end

      # Return Array of reply email accounts
      return email_accounts
  end



  def post_campaign(scalerep_campaign, key, email_to_use)
      begin
          payload = {"name": scalerep_campaign.campaign_name, "emailAccount": email_to_use, "settings": { "EmailsCountPerDay": 400, "daysToFinishProspect": 3, "daysFromLastProspectContact": 3, "emailSendingDelaySeconds": 180, "emailPriorityType": "Equally divided between", "disableOpensTracking": false, "repliesHandlingType": "Mark person as finished", "enableLinksTracking": false }, "steps": [{ "number": "1", "InMinutesCount": "25", "templates": [{ "body": "Hello World!", "subject": "Im here!"}]}]}.to_json
          response = RestClient.post "https://api.reply.io/v2/campaigns?apiKey="+key, payload, :content_type => "application/json"
          data_hash = JSON.parse(response)

          scalerep_campaign.update_attribute(:reply_id, data_hash["id"])
          scalerep_campaign.update_attribute(:reply_key, key)

          return response
      rescue RestClient::ExceptionWithResponse => e

          puts e
          return e
      end

  end


  def count_campaigns_per_email(email_array, campaign_array)
      count_dic = Hash.new
      
      for email in email_array
        count_dic[email["emailAddress"]] = 0
      end

      for campaign in campaign_array
          for reply_email in email_array
              if campaign.emailAccount == reply_email["emailAddress"]
                  if count_dic[campaign.emailAccount]
                      count_dic[campaign.emailAccount] = count_dic[campaign.emailAccount] + 1
                  else
                      count_dic[campaign.emailAccount] = 1
                  end
              end
         end
      end
      return count_dic
  end

  # Find the correct keys for that email to upload the campaign to that email
  def get_reply_key_for_campaign(email_to_match, reply_array) 
      for email in reply_array
        if email_to_match == email["emailAddress"]
          reply_key = email["key"]
          break
        end
      end
      return reply_key
  end



end
