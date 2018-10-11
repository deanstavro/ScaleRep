class MetricsController < ApplicationController

  before_action :authenticate_user!

  def index
    @user = User.find(current_user.id)
  
    if @user.role == "scalerep"
      @client_companies = ClientCompany.all.pluck(:name)
      if params.has_key?(:client_company)
          @company = ClientCompany.find_by(name: params["client_company"])
      else
          @company = ClientCompany.find_by(id: @user.client_company_id)
      end
    else
          @company = ClientCompany.find_by(id: @user.client_company_id)
    end
    
  	@touchpoints = Touchpoint.where(['client_company_id = ? and created_at >= ?', @company, Date.today - 7.days])
  	@lead_actions = LeadAction.where(['client_company_id = ? and email_sent_time >= ?',@company, Date.today - 7.days ])
  	@email_opens = @lead_actions.where(['action = ? and first_time = ?', LeadAction.actions[:open], 'True'])
    @email_replies = @lead_actions.where(['action = ?', LeadAction.actions[:reply]])

    @meetings_set = Lead.where(client_company_id: @company.id).where(:status => ["handed_off", "handed_off_with_questions", "sent_meeting_invite"]).order('date_sourced DESC').paginate(:page => params[:page], :per_page => 10)
  end

end
