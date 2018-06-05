class AutoRepliesToReplyIoJob < ApplicationJob
  queue_as :default
  include Reply

  def perform(*args)
    puts "grabbing all auto-replies from today"

    # grab all replies marked as today

    begin
        @auto_replies = AutoReply.where(:follow_up_date => Date.today)


        begin


            @auto_replies.each do |auto_reply|

                response = add_contact('dB55wd_oObuQofMmwc93lw2','149275', auto_reply)
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
