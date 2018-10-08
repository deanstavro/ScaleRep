class MetricsController < ApplicationController

  before_action :authenticate_user!

  def index
    @user = User.find(current_user.id)
	@company = ClientCompany.find_by(id: @user.client_company_id)

	@touchpoints = Touchpoint.where(['client_company_id = ? and created_at >= ?', @company, Date.today - 7.days])
    @lead_actions = LeadAction.where(['client_company_id = ? and first_time = ? and created_at >= ?', @company, 'True', Date.today - 7.days ])
    @meetings_set = Lead.where(client_company_id: @company.id).where(:status => ["handed_off", "handed_off_with_questions", "sent_meeting_invite"]).order('updated_at DESC').paginate(:page => params[:page], :per_page => 20)

  end

end
