class AutoRepliesToReplyIoJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "grabbing all auto-replies from today"

    # grab all replies marked as today
    @auto_replies = AutoReply.where(:follow_up_date =>Date.today)
    puts @auto_replies

    # now, need to go from auto_replies to campaigns and contacts

    # call job to send to the correct campaign
    # loop through each auto_reply and call to_campaign information
    @auto_replies.each do |auto_reply|

    end

  end
end
