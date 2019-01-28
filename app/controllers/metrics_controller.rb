class MetricsController < ApplicationController

  before_action :authenticate_user!

  def index
    @user = User.find(current_user.id)

    # to display metrics by company
    if @user.role == "scalerep"
        @client_companies = ClientCompany.where("account_live = ?", true).pluck(:name)
        if params.has_key?(:client_company)
            @company = ClientCompany.find_by(name: params["client_company"])
        else
            @company = ClientCompany.find_by(id: @user.client_company_id)
        end
    else
          @company = ClientCompany.find_by(id: @user.client_company_id)
    end

    # what time_frame
    if params.has_key?("time_frame")
      @time_frame = params["time_frame"]

      if @time_frame == "By Week"
        @range = Date.today - 56.days
      else
        @range = Date.today - 240.days
      end
      
    else
      @time_frame = "Last 7 Days"
      @range = Date.today - 7.days
    end





  	@touchpoints = Touchpoint.where(['client_company_id = ? and created_at >= ?', @company, @range])
  	@lead_actions = LeadAction.where(['client_company_id = ? and email_sent_time >= ?',@company, @range ])
  	@email_opens = @lead_actions.where(['action = ? and first_time = ?', LeadAction.actions[:open], 'True'])
    @email_replies = @lead_actions.where(['action = ?', LeadAction.actions[:reply]])
    @meetings_set = Lead.where(client_company_id: @company.id).where(:status => ["handed_off", "handed_off_with_questions", "sent_meeting_invite"]).order('date_sourced DESC').paginate(:page => params[:page], :per_page => 10)
  end

end
