class DataTasksController < ApplicationController
  before_action :authenticate_user!
  require 'date'; 

  # Calculates date ranges, get client companies, to display prospecting and engagement
  # board for client directors
  def index
	@user = User.find(current_user.id)

	if @user.role != 'scalerep'
		redirect_to root_path, :flash => { :error => "Data Tasks - Please Contact ScaleRep for more info!" }  	
	end

	@client_companies = ClientCompany.where("account_live = ?", true)
	
	now = DateTime.now
	@lastSunday = (now - now.wday).strftime("%b %d").to_s
	@nextSunday = (now - now.wday + 6).strftime("%b %d").to_s

	#For Query to grab lead count
	@lastSundayQuery = (now - now.wday)


  end

end
