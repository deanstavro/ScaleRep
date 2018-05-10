module CampaignsHelper
  def reply_rate_calcularor(replies_count, deliveries_count)
    percentage = if deliveries_count.zero?
                   0
                 else
                   (replies_count / deliveries_count) * 100
                 end
    number_to_percentage percentage
  end
end
