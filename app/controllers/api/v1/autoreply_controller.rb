class Api::V1::AutoreplyController < ApplicationController

  def new_reply
    puts "WATSUP"
    # get information from params and print somewhere
    @client_company = ClientCompany.find_by(api_key: params[:company_api_key])

    puts params

    @params_content = params["autoreply"]

    # grab all relevant information and put into auto_reply database
    # determine what an be updated from webhook


    # Remove all fields that are not to be saved
    @params_content.delete("company_api_key")
    puts "2nd beez"
    puts @params_content


    @auto_reply = AutoReply.new(auto_reply_params)
    @auto_reply.save

    # finish filling out information
    #@auto_reply.client_company = @client_company


  end

  private
    # Never trust parameters from the scary internet,
    # only allow the white list through.
    def auto_reply_params
      @params_content.permit(:first_name, :last_name, :lead_email, :follow_up_date, :lead_status)
    end
end
