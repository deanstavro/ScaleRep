class Api::V1::ReplyController < Api::V1::BaseController
  
    

    def new_reply
        
        unless params[controller_name.to_s].empty?

            # grab reply params, with the json content
            @params_content = params[controller_name.to_s]
            
            begin
                # Create new lead with secured params
                @campaign_reply = CampaignReply.new(auto_reply_params)
            rescue
                puts "wrong status"
                render json: {error: "Reply was not uploaded. Wrong status input.", :status => 400}, status: 400
                return
            end

            # Update lead to the correct company
            @client_company = ClientCompany.find_by(api_key: params["api_key"])
            update_reply(:client_company, @client_company)




            if @params_content.key?(:status)

                #get all lead status enums
                statuses = get_reply_statuses

                for status in statuses
                    puts "YUP"
                    puts status

                    if status[0].to_s == @params_content[:status].to_s

                        puts "updating " + __method__.to_s
                        update_reply(:status, @params_content[:status].to_s)
                        puts "updated"

                    end
                    puts status[0]+ " not found"

                        
                end

            else
                puts "no status"
                render json: {error: "Reply was not uploaded. Please include status.", :status => 400}, status: 400
                return
            end


            #begin
                


                if @params_content[:status].to_s == "opt_out" or @params_content[:status].to_s == "do_not_contact"
                    update_lead(@params_content, @client_company, @campaign_reply, "blacklist")
                    render json: {response: "Reply uploaded", :status => 200}, status: 200
                    return
                elsif @params_content[:status].to_s == "interested" or @params_content[:status].to_s == "not_interested"
                    update_lead(@params_content, @client_company, @campaign_reply, @params_content[:status].to_s)
                    render json: {response: "Reply uploaded", :status => 200}, status: 200
                    return
                else
                    update_lead(@params_content, @client_company, @campaign_reply, "in_campaign")
                    render json: {response: "Reply uploaded", :status => 200}, status: 200
                    return
                    
                end


                

            #rescue
                puts "did not save"
                render json: {error: "Reply was not uploaded. E-mail required fields missing (email)", :status => 400}, status: 400
                return
            #end

        else
            puts "params empty"
            render json: {error: "Reply was not uploaded. JSON post parameters missing", :status => 400}, status: 400
            return
        end


    end




    private


    # Never trust parameters from the scary internet,
    # only allow the white list through.
    def auto_reply_params
        @params_content.permit(:first_name, :last_name, :full_name, :last_conversation_subject, :last_conversation_summary, :email, :date_sourced, :status)
    end
    
    def get_reply_statuses
        return CampaignReply.statuses
    end

    def update_reply(field, value)
        @campaign_reply.update_attribute(field, value)
    end

    def update_lead(params_content, client_company, campaign_reply, status)

                    @lead = Lead.where(:client_company => client_company, :email => campaign_reply.email)


                    if @lead.empty?
                        @new_lead = @lead.create!(:email => campaign_reply.email, :status => status)
                        campaign_reply.update_attribute(:lead, @new_lead)
                        campaign_reply.save!
                    else
                        for lead in @lead
                            lead.update(status: status)
                            campaign_reply.update_attribute(:lead, lead)
                            campaign_reply.save!
                        end

                        #####################
                        #Here, update the lead with the reply task
                    end


    end


end
