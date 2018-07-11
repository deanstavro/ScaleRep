class ReferralsToReplyJob < ApplicationJob
  queue_as :default
  include Reply

  def perform(*args)
    


  end
end
