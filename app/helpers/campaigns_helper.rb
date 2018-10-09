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

  def getEmailOpens(campaign)
    email_open_count = 0
    touchpoints = campaign.touchpoints
    
    for tp in touchpoints
      l_a = tp.lead_actions.where(["action = ?", LeadAction.actions[:open]])
      email_open_count += l_a.count
    end
    
    return email_open_count
  end

  def getUniqueEmailOpens(campaign)
    email_open_count = 0
    touchpoints = campaign.touchpoints
    
    for tp in touchpoints
      l_a = tp.lead_actions.where(["action = ? and email_open_number = ?", LeadAction.actions[:open], "1"])
      email_open_count += l_a.count
    end
    
    return email_open_count
  end

  def getEmailReplies(campaign)
    email_open_count = 0
    touchpoints = campaign.touchpoints
    
    for tp in touchpoints
      l_a = tp.lead_actions.where(["action = ?", LeadAction.actions[:reply]])
      email_open_count += l_a.count
    end
    
    return email_open_count
  end


end
