class MetricsController < ApplicationController
	
before_action :authenticate_user!

  def index
    @user = User.find(current_user.id)

    @company = @user.client_company_id
    
    @leads = Lead.where("client_company_id =? " , @company)
    @ordered_leads = @leads.sort_by &:date_sourced
    

    #@leads_count = @leads.count
    #@contracts = @leads.where(contract_amount: 1..Float::INFINITY).sort_by &:date_sourced
    #@contracts_given = @contracts.sort_by &:date_sourced
    #@contracts_count = @contracts_given.count
    #@unconverted = @leads.count - @contracts_given.count


    
    #Create line chart value for aggregated proposed deal sizes
    lead_proposed_dictionary = {}
    @ordered_leads.each do |lead|

      #key, value of all leads and deals

      if lead_proposed_dictionary.has_key?(lead[:date_sourced])
        lead_proposed_dictionary[lead[:date_sourced]] += lead[:potential_deal_size]        

      else
        lead_proposed_dictionary[lead[:date_sourced]] = lead[:potential_deal_size]

      end

    end

  end

end
