class Api::V1::AutoReplyController < ApplicationController
  def new
    # get information from params and print somewhere
    @client_company = ClientCompany.find_by(api_key: params[:company_api_key])

    puts params
    puts params[:company_api_key]

    # grab all relevant information and put into auto_reply database
    # determine what an be updated from webhook
    @auto_reply = AutoReply.new(auto_reply_params)

    # finish filling out information
    @auto_reply.client_company = @client_company


  end

  private
    # Never trust parameters from the scary internet,
    # only allow the white list through.
    def auto_reply_params
      params.require(:first_name).require(:last_name).require(:email).permit(:follow_up_date, :lead_status)
    end
end
