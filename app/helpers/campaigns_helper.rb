module CampaignsHelper
  def reply_rate_calculator(replies_count, deliveries_count)
  	puts "REP"
  	puts replies_count
  	puts "DEL"
  	puts deliveries_count
    percentage = if deliveries_count.zero?
    				puts "NO"
                   0
                 else
                 	puts "ES"
                   ((replies_count.round(1) / deliveries_count)*100).round(1)
                 end
    number_to_percentage percentage
  end
end
