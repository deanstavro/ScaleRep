class Api::V1::AutoreplyController < Api::V1::BaseController
  
    def out_of_office

        # get information from params and print somewhere
        #@client_company = ClientCompany.find_by(api_key: params[:company_api_key])
        

        @params_content = params["autoreply"]

        # grab all relevant information and put into auto_reply database
        # Remove all fields that are not to be saved
        #t.delete("company_api_key")
        @lead = Lead.new(auto_reply_params)

        # finish filling out information --> campaign and company_api_key
        #@auto_reply.client_company = @client_company

        # find campaign for company that IS an auto_reply campaign
        #company_auto_reply_campaign = Campaign.where(:client_company => @client_company, :campaign_type => "auto_reply").first

        #puts "company_auto_reply_campaign!"
        #puts company_auto_reply_campaign

        #@auto_reply.campaign = company_auto_reply_campaign
        @lead.save


        #@auto_reply.client_company = @client_company


    end


    def referral
        @params_content = params["referral"]
        @lead = Lead.new(auto_reply_params)
        @lead.save
    end


    private


    # Never trust parameters from the scary internet,
    # only allow the white list through.
    def auto_reply_params
        @params_content.permit(:first_name, :last_name, :full_name, :last_conversation_subject, :last_conversation_summary, :email, :date_sourced, :status)
    end
    
end
