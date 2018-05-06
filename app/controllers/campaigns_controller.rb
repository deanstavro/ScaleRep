class CampaignsController < ApplicationController
	before_action :authenticate_user!

	def index
    	@user = User.find(current_user.id)

  		@company = ClientCompany.find_by(id: @user.client_company_id)

    	# grab reports and grab leads for every week for a report
    	@campaigns = Campaign.where("client_company_id =?", @company).order('created_at DESC')

  	end


  	def new
    	@user = User.find(current_user.id)

  		@company = ClientCompany.find_by(id: @user.client_company_id)
  		@campaign = Campaign.new

  	end


  	def create
    	@user = User.find(current_user.id)
  		@company = ClientCompany.find_by(id: @user.client_company_id)

  		@campaign = @company.campaigns.build(campaign_params)

  		if @campaign.save
  			redirect_to campaigns_path, :notice => "Campaign created"
    	else
      		redirect_to campaigns_path, :alert => "Campaign updated"
    	end


  	end


  	private

  	
  	def campaign_params
  		params.require(:campaign).permit(:name, :persona, :user_notes)
  	end	

end
