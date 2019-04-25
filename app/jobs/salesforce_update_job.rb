class SalesforceUpdateJob < ApplicationJob
  include Salesforce_Integration

  queue_as :default

  def perform(object, salesforce)
    puts "#########"
    puts "in the SalesforceUpdateJob"
    puts "#########"

    # logic to determine which job to call
    if object.instance_of? CampaignReply
      puts "successfully determined this is a CampaignReply"
      upload_replies_to_salesforce(object, salesforce)

      

    end
  end
end
