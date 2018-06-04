class Api::V1::AutoreplyController < ApplicationController

  def new_reply
    puts "WATSUP"
    # get information from params and print somewhere
    @client_company = ClientCompany.find_by(api_key: params[:company_api_key])
    @params_content = params["autoreply"]

    # grab all relevant information and put into auto_reply database
    # Remove all fields that are not to be saved
    @params_content.delete("company_api_key")
    @auto_reply = AutoReply.new(auto_reply_params)

    # finish filling out information --> campaign and company_api_key
    @auto_reply.client_company = @client_company

    # find campaign for company that IS an auto_reply campaign
    company_auto_reply_campaign = Campaign.where(:client_company => @client_company, :campaign_type => "auto_reply").first

    puts "company_auto_reply_campaign!"
    puts company_auto_reply_campaign

    @auto_reply.campaign = company_auto_reply_campaign
    @auto_reply.save


    #@auto_reply.client_company = @client_company


  end

  private
    # Never trust parameters from the scary internet,
    # only allow the white list through.
    def auto_reply_params
      @params_content.permit(:first_name, :last_name, :lead_email, :follow_up_date, :lead_status)
    end
end
