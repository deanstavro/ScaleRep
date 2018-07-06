class ReferralsToReplyJob < ApplicationJob
  queue_as :default
  include Reply

  def perform(*args)
    puts "grabbing all referrals from today"

    # grab all replies marked as today

    begin
        @campaign_replies = CampaignReply.where(follow_up_date: Date.today, :status => ["referral", "auto_reply_referral"])

        puts "we got campaign replies"

        begin

            @campaign_replies.each do |referral|
              unless (referral.referral_email.nil? || referral.referral_email=="") and (referral.referral_name.nil? || referral.referral_name == "") and referral.full_name.nil?
                @client_company = referral.client_company
                puts "about to execute add_contact for referral"
                response = add_referral_contact(@client_company.referral_campaign_key,@client_company.referral_campaign_id, referral)
              end
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
