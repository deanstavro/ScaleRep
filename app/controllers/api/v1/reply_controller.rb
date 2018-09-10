class Api::V1::ReplyController < Api::V1::BaseController

    def email_open
      puts "e-mail has been opened. Webhook for Reply.io"
      puts params.to_s

      unless params.empty?
        #{"opens_count":"4", "campaign_step":"1", "last_name":"Lussier", "first_name":"Samantha", "first_time_open":"False", "campaign_name":"Better | Email Dump | 3110-3410", "email":"samanthalussierpsyd@gmail.com"}
        #"api_key"=>"b4e330f5cda737343261c5c978266211", "controller"=>"api/v1/reply", "action"=>"email_open", 
        #"reply"=><ActionController::Parameters {"opens_count"=>"4", "campaign_step"=>"1", "last_name"=>"Lussier", "first_name"=>"Samantha",
        # "first_time_open"=>"False", "campaign_name"=>"Better | Email Dump | 3110-3410", "email"=>"samanthalussierpsyd@gmail.com"} 
        #permitted: false>}
        begin

            client_company = ClientCompany.find_by(api_key: params["api_key"])

            campaign_to_update = Campaign.find_by client_company: client_company, campaign_name: params["campaign_name"]

            # update the total_opens in the campaign
            total_opens = campaign_to_update.opensCount
            if total_opens.present?
                count = campaign_to_update.opensCount
                campaign_to_update.update_attribute(:opensCount, count + 1)

            else
                campaign_to_update.update_attribute(:opensCount, 1)

            end
            
            if campaign_to_update.uniqueOpens.present?
              

              # update the unqiue opens in the campaign
              if params["first_time_open"] != "False"


              
                begin
                  old_count = campaign_to_update.uniqueOpens # Create new campaign reply
                  count = old_count + 1
                rescue
                  count = 1
                end

                campaign_to_update.update_attribute(:uniqueOpens, count)

                render json: {response: "Campaign total opens updated. E-mail unique opened updated", :status => 200}, status: 200
                return

              else

                puts "User has already opened"
                render json: {response: "Campaign total opens updated. Unique contacts opened not updated", :status => 200}, status: 200
                return

              end

              

            end

            render json: {response: "Campaign total opens updated. Unique contacts opened not updated", :status => 200}, status: 200
            return
            # @campaign_reply = CampaignReply.new(auto_reply_params)

            # Check if lead exists
              # if it does, update
                # Update the campaign it is in
              # if not, create a new lead
                # Find the campaign, update

            

        rescue

            puts "could not find company or campaign for company"
            render json: {error: "could not find company or campaign for company", :status => 200}, status: 200
            return

        end

      else
            puts "params empty"
            render json: {error: "Empty params received from Reply.io", :status => 400}, status: 400
            return
      end



    end

    # API to catch all from front app
    # This api adds a new campaign_reply object, and then updates the lead's status

    # API example payload
    # {"status": "auto_reply","last_conversation_subject": "Thank you for your email! Re: insurance question","email": "info@caninetherapycorps.org","last_conversation_summary": " Thank you so much for contacting Canine Therapy Corps! Your inquiry is important to us. We have a small staff, so please be patient. We will get back to you as soon as we can. If you do not receive a","full_name": "Canine Therapy Corps Inc."}
    def new_reply
        puts "New Tag from FrontApp received. Running new_reply API"
        puts "DATA IN: " + params.to_s
        # Check if params are present
        unless params[controller_name.to_s].empty?

            begin

                # Make campaign_reply
                @params_content = params[controller_name.to_s]

                # Check if matching status exists, or return error
                if @params_content.key?(:status)

                  #get all lead status enums
                  statuses = get_reply_statuses
                  correct_status = false
                  for status in statuses
                    if status[0].to_s == @params_content[:status].to_s
                        puts "Status for reply in  " + __method__.to_s + " api is " + status[0].to_str
                        correct_status = true
                        break
                    end
                  end

                  # If incorrect status included, return 400
                  if correct_status == false
                    render json: {error: "Wrong status included. Please input the correct status name and try again", :status => 400}, status: 400
                    return
                  end

                # stauts not included in payload
                else
                    render json: {error: "Reply was not uploaded. Please include status field and value.", :status => 400}, status: 400
                    return
                end

                # Create campaign reply
                @campaign_reply = CampaignReply.new(auto_reply_params)

                # Try to add campaign_reply first and last name using the full name passed through the API
                begin
                  if @campaign_reply[:full_name].split.length < 2
                    @campaign_reply.update_attributes( :first_name => @campaign_reply[:full_name], :last_name => 'N/A')
                    puts "Full name: " + @campaign_reply[:full_name]
                  else
                    first_name = @campaign_reply[:full_name].split[0...-1].join(" ").tr(",","")
                    @campaign_reply.update_attributes(:first_name => first_name, :last_name => @campaign_reply[:full_name].split[-1])
                    puts "Full name: " + first_name + " " + @campaign_reply[:full_name].split[-1]
                  end
                # could not update name
                rescue
                  @campaign_reply.update_attributes(:first_name => 'N/A', :last_name => 'N/A')
                end

                #set pushed_to_reply_campaign false
                @campaign_reply.update_attribute(:pushed_to_reply_campaign, false)

            rescue
                render json: {error: "Reply was not uploaded. Wrong status input, or bad payload.", :status => 400}, status: 400
                return
            end

            ##### Campaign Reply object created and updated. Time to associate reply to the correct company, and lead  ##########
            # Update lead to the correct company
            @client_company = ClientCompany.find_by(api_key: params["api_key"])
            @campaign_reply.update_attribute(:client_company, @client_company)

            #begin
                if @params_content[:status].to_s == "opt_out" or @params_content[:status].to_s == "do_not_contact"
                    update_lead(@params_content, @client_company, @campaign_reply, "blacklist")
                    render json: {response: "Reply uploaded", :status => 200}, status: 200
                    return
                elsif @params_content[:status].to_s == "interested" or @params_content[:status].to_s == "not_interested" or @params_content[:status].to_s == "handed_off" or @params_content[:status].to_s == "handed_off_with_questions" or @params_content[:status].to_s == "sent_meeting_invite"
                    update_lead(@params_content, @client_company, @campaign_reply, @params_content[:status].to_s)
                    render json: {response: "Reply uploaded", :status => 200}, status: 200
                    return
                else
                    update_lead(@params_content, @client_company, @campaign_reply, "in_campaign")
                    render json: {response: "Reply uploaded", :status => 200}, status: 200
                    return

                end
            #rescue
             #   render json: {error: "Reply was not uploaded. E-mail required fields missing (email)", :status => 400}, status: 400
              #  return
            #end

        else
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
          
          if params_content[:full_name].split.length < 2
              f_name = @campaign_reply[:full_name]
              l_name = 'N/A'
          else
              f_name = @campaign_reply[:full_name].split[0...-1].join(" ").tr(",","")
              l_name = @campaign_reply[:full_name].split[-1]
          end

          new_lead = @lead.create!(:email => campaign_reply.email, :status => status, :full_name => params_content[:full_name], :first_name => f_name, :last_name => l_name, :client_company => client_company)
          campaign_reply.update_attribute(:lead, new_lead)
          campaign_reply.save!

          #check for first and last name
          
      else
          for lead in @lead
              lead.update(status: status)
              campaign_reply.update_attribute(:lead, lead)
              campaign_reply.save!
          end
      end
    end


end
