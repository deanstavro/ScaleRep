class AutoRepliesToReplyIoJob < ApplicationJob
  queue_as :default
  include Reply

  def perform(*args)
    puts "grabbing all auto-replies from today"

    # grab all replies marked as today

    begin
        @campaign_replies = CampaignReply.where(follow_up_date: Date.today, :status => ["auto_reply", "auto_reply_referral"])

        puts "we got campaign replies: "

        begin

            @campaign_replies.each do |auto_reply|
                @client_company = auto_reply.client_company
                puts "about to execute remove_contact"
                response = remove_contact(@client_company.auto_reply_campaign_key, auto_reply["email"])
                puts "about to execute add_contact"
                response = add_contact(@client_company.auto_reply_campaign_key,@client_company.auto_reply_campaign_id, auto_reply)

                # to-do: update lead status in our system as auto-reply

                #to-do: update attribute
                auto_reply.update_attribute(:pushed_to_reply_campaign, !auto_reply.pushed_to_reply_campaign)
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
