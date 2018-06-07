class MetricsController < ApplicationController

  before_action :authenticate_user!

  def index
    @user = User.find(current_user.id)

		@company = ClientCompany.find_by(id: @user.client_company_id)

		""" leads as if theya re pulled from our database
				right now, they are pulled from airtabler
		"""
    #@leads = Lead.where(:client_company_id => @company, :meeting_set => true)
    #@ordered_leads = @leads.sort_by &:date_sourced

		# airtable work
		airtable = @company.airtable_keys
    airtable_dic = eval(airtable)
    puts airtable_dic["AIRTABLE"]

		table = Airrecord.table(airtable_dic["AIRTABLE"],airtable_dic["MOFU"],"MOFU")

		warm_leads = table.all(filter: '{lead_status} = "warm_lead"', sort: {qualified_date: "desc"})
		qualified_leads = table.all(filter: '{lead_status} = "qualified"', sort: {qualified_date: "desc"})

		@warm_qualified_leads = warm_leads + qualified_leads

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
