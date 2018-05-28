module CampaignsHelper
  def reply_rate_calculator(replies_count, deliveries_count)
  	puts "REP"
  	puts replies_count
  	puts "DEL"
  	puts deliveries_count
    percentage = if deliveries_count.zero?
                   0
                 else
                   Float((replies_count.to_f)*100 / deliveries_count).round(2)
                 end
   percentage
  end
end
