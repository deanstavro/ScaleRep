class MetricsController < ApplicationController

  before_action :authenticate_user!

  def index
    @user = User.find(current_user.id)

		@company = ClientCompany.find_by(id: @user.client_company_id)

		""" leads as if theya re pulled from our database
				right now, they are pulled from airtabler
		"""
    

    #@leads_count = @leads.count
    #@contracts = @leads.where(contract_amount: 1..Float::INFINITY).sort_by &:date_sourced
    #@contracts_given = @contracts.sort_by &:date_sourced
    #@contracts_count = @contracts_given.count
    #@unconverted = @leads.count - @contracts_given.count



    #Create line chart value for aggregated proposed deal sizes
    @leads = []

    if @warm_qualified_leads.size < 1
      puts "no leads"

		else
      @warm_qualified_leads.each do |lead|
      	@leads.push(lead.fields)
			end
    end



  end

end
