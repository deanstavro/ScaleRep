class Api::V1::ReplyController < Api::V1::BaseController

    def new_reply
        unless params[controller_name.to_s].empty?

            # grab reply params, with the json content
            @params_content = params[controller_name.to_s]

            begin
                # first check to see if this exists
                @campaign_reply = nil
                if CampaignReply.exists?(email: params["email"])
                  @campaign_reply = CampaignReply.find_by(email: params["email"])
                else
                  # Create new lead with secured params
                  @campaign_reply = CampaignReply.new(auto_reply_params)
                end

                #if first_name and last_name are empty --> assign
                if !@campaign_reply[:first_name] and !@campaign_reply[:last_name]
                  if @campaign_reply[:full_name].split.length < 2
                    update_reply(:first_name, @campaign_reply[:full_name])
                  else
                    update_reply(:last_name, @campaign_reply[:full_name].split[-1])
                    update_reply(:first_name, @campaign_reply[:full_name].split[0...-1].join(" "))
                  end
                end

                #set pushed_to_reply_campaign false
                update_reply(:pushed_to_reply_campaign, false)

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
            elsif @params_content[:status].to_s == "interested" or @params_content[:status].to_s == "not_interested" or @params_content[:status].to_s == "handed_off"
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
          @new_lead = @lead.create!(:email => campaign_reply.email, :status => status, :full_name => params_content[:full_name])
          campaign_reply.update_attribute(:lead, @new_lead)
          campaign_reply.save!

          #check for first and last name
          @new_lead.update_attribute(:full_name, params_content[:full_name])
          if params_content[:full_name].split.length < 2
            @new_lead.update_attribute(:first_name, params_content[:full_name])
          else
            @new_lead.update_attribute(:last_name, params_content[:full_name].split[-1])
            @new_lead.update_attribute(:first_name, params_content[:full_name].split[0...-1].join(" "))
          end



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
