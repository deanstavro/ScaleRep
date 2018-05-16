class UpdateCampaignsJob < ApplicationJob
  queue_as :default
  include Reply

  after_perform do |job|
    # invoke another job at your time of choice 
    self.class.set(:wait => 2.hours).perform_later(job.arguments.first)
  end
  def perform(*args)
    # @campaigns = Campaign.where.not(reply_key: nil).where.not(reply_key: "")
    # Call app/lib/reply.get_campaigns module to get all campaigns from reply.io
    # @campaign_array = get_campaigns(@company.replyio_keys)



    end
  end