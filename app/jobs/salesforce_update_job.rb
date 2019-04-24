class SalesforceUpdateJob < ApplicationJob
  queue_as :default

  def perform(object)
    puts "#########"
    puts "in the SalesforceUpdateJob"
    puts "#########"

    
  end
end
