class AutoRepliesToReplyIoJob < ApplicationJob
  queue_as :default
  include Reply

  def perform(*args)
    puts "grabbing all auto-replies from today"

    # grab all replies marked as today

    begin
        @campaign_replies = CampaignReply.where(:follow_up_date => Date.today)


        begin


            @campaign_replies.each do |auto_reply|

                @client_company = auto_reply.client_company
                puts @client_company.auto_reply_campaign_key
                puts @client_company.auto_reply_campaign_id
                response = add_contact(@client_company.auto_reply_campaign_key,@client_company.auto_reply_campaign_id, auto_reply)
                sleep 10
            end

        rescue

          puts "ERROR"
          return "ERROR"

        end
    rescue
        puts "No auto replies exist!"

    end
        
    
  end
end
