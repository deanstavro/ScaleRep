class Api::V1::ReplyController < Api::V1::BaseController

    
    def email_reply
        begin
            puts "e-mail reply notification has been received from reply.io"

            if emptyPostParams(params["reply"])
                render json: {response: "Empty payload.", :status => 400}, status: 400
                return
            end

            client_company = ClientCompany.find_by(api_key: params["api_key"])
            # Find campaign or return if nil
            campaign = Campaign.find_by(client_company: client_company, campaign_name: params["reply"]["campaign_name"])
            if campaign.nil?
                render json: {response: "Couldn't find campaign for campaign name " + params["reply"]["campaign_name"], :status => 200}, status: 200
                return
            end
            # Find lead or return if nil
            lead = Lead.where(["lower(email) = ? AND leads.client_company_id = ?", params["reply"]["email"].downcase, client_company]).first
            if lead.nil?
                render json: {response: "Couldn't find lead for email " + params["reply"]["email"], :status => 200}, status: 200
                return
            end
            # Find touchpoint or return nil
            num = params["reply"]["campaign_step"].to_i - 1
            lead_touchpoint = lead.touchpoints.where(["campaign_id = ?", campaign])[num]
            if lead_touchpoint.nil?
                render json: {response: "Couldn't find touchpoint to associate to email open", :status => 200}, status: 200
                return
            end

            email_sent_time = lead_touchpoint.created_at
            lead_action = LeadAction.create!(:lead => lead, :client_company => client_company, :touchpoint => lead_touchpoint, :action => :reply, :email_open_number => params["opens_count"], :email_sent_time => email_sent_time)
            campaign.update_attribute(:repliesCount, campaign.repliesCount + 1)
            render json: {response: "new reply created", :status => 200}, status: 200
            return
        rescue
            render json: {response: "Error - contact ScaleRep's tech department.", :status => 400}, status: 400
            return
        end
    end

    # Touchpoint is created
    # Associated to a found lead, or a new lead is created
    # Lead is moved to in_campaign
    def email_sent
        puts "e-mail sent notification has been received from reply.io"

        # catch any errors and have client contact us
        begin

            if emptyPostParams(params["reply"])
                render json: {response: "Empty payload.", :status => 400}, status: 400
                return
            end

            client_company = ClientCompany.find_by(api_key: params["api_key"])

            campaign = Campaign.find_by(client_company: client_company, campaign_name: params["reply"]["campaign_name"])
            if campaign.nil?
                render json: {response: "Couldn't find campaign", :status => 200}, status: 200
                return
            end
            
            lead = Lead.where(["lower(email) = ? AND leads.client_company_id = ?", params["reply"]["email"].downcase, client_company]).first
            #Get lead, or create if needed
            if lead.nil?
                #create lead
                puts "lead to associate touchpoint does not exist. return"
                begin
                    full_name = params["reply"]["first_name"] + " " + params["reply"]["last_name"]
                rescue
                    full_name = params["reply"]["first_name"]
                end

                client_leads = client_company.leads

                lead = Lead.create!(:email => params["reply"]["email"], :first_name => params["reply"]["first_name"], :last_name => params["reply"]["last_name"], :full_name => full_name, :client_company => client_company, :campaign => campaign, :status => "in_campaign")
                campaign.update_attribute(:peopleCount, campaign.peopleCount + 1)
            else
                #if lead.campaign != campaign
                #    render json: {error: "Lead campaign does not equal campaign from the email sent. Contact ScaleRep's tech department", :status => 400}, status: 400
                #    return
                #else 
                if lead.status != :in_campaign
                    lead.update_attribute(:status, "in_campaign")
                end
                #end
            end

            #Create touchpoint and associate to lead
            puts "creating touchpoint. Associating to lead and campaign"
            touchpoint = Touchpoint.create!(:channel => :email, :sender_email => params["reply"]["sender_email"], :email_subject => params["reply"]["email_subject"], :email_body => params["reply"]["email_body"], :campaign => campaign, :lead => lead, :client_company => client_company)
            campaign.update_attribute(:deliveriesCount, campaign.deliveriesCount + 1)

            render json: {response: "Touchpoint created", :status => 200}, status: 200
            return
        rescue
            render json: {error: "contact ScaleRep's tech department", :status => 400}, status: 400
            return
        end
    end




    # Captures all e-mail opens from reply
    # API payload example: {"opens_count":"4", "campaign_step":"1", "last_name":"Lussier", "first_name":"Samantha", "first_time_open":"False", "campaign_name":"Better | Email Dump | 3110-3410", "email":"samanthalussierpsyd@gmail.com"},"api_key"=>"b4e330f5cda737343261c5c978266211", "controller"=>"api/v1/reply", "action"=>"email_open", "reply"=><ActionController::Parameters {"opens_count"=>"4", "campaign_step"=>"1", "last_name"=>"Lussier", "first_name"=>"Samantha","first_time_open"=>"False", "campaign_name"=>"Better | Email Dump | 3110-3410", "email"=>"samanthalussierpsyd@gmail.com"} permitted: false>}
    
    # Associated to lead, or returned
    # Associated to touchpoint, or returned
    # If lead_action can be associated to touchpoint and lead, it is created
    def email_open
        puts "e-mail has been opened front reply.io"

        if emptyPostParams(params["reply"])
            render json: {error: "Empty payload.", :status => 400}, status: 400
            return
        end

        begin

            client_company = ClientCompany.find_by(api_key: params["api_key"])
            # Find campaign or return
            campaign_to_update = Campaign.find_by client_company: client_company, campaign_name: params["campaign_name"]
            if campaign_to_update.nil?
                render json: {response: "Couldn't find campaign for campaign name " + params["campaign_name"], :status => 200}, status: 200
                return
            end
            # Find lead or return
            lead = Lead.where(["lower(email) = ? AND leads.client_company_id = ?", params["email"].downcase, client_company]).first
            if lead.nil?
                render json: {response: "Couldn't find lead for email " + params["email"], :status => 200}, status: 200
                return
            end

            # Find if any touchpoints exist or return error
            tps = lead.touchpoints.where(['campaign_id = ?', campaign_to_update])
            if tps.empty?
                render json: {response: "Couldn't find any touchpoints for campaign " + campaign_to_update.campaign_name + " and for lead " + lead.email, :status => 200}, status: 200
                return
            end

            #For touchpoints, check if an action has been taken
            opened_email = false
            for t in tps
                if !t.lead_actions.first.nil?
                    opened_email = true
                    break
                end
                
            end

            if !opened_email 
                campaign_to_update.update_attributes(:opensCount => campaign_to_update.opensCount + 1, :uniqueOpens => campaign_to_update.uniqueOpens + 1)
            elsif params["reply"]["opens_count"].to_i == 1
                campaign_to_update.update_attribute(:opensCount, campaign_to_update.opensCount + 1)
            end

            # Find campaign step number
            num = params["reply"]["campaign_step"].to_i - 1
            puts "NUM: " + num.to_s
            lead_touchpoint = lead.touchpoints.where(["campaign_id = ?", campaign_to_update])[num]


            if lead_touchpoint.nil?
                render json: {response: "Couldn't find touchpoint associate to email open", :status => 200}, status: 200
                return
            end

            email_sent_time = lead_touchpoint.created_at
            lead_action = LeadAction.create!(:lead => lead, :client_company => client_company, :touchpoint => lead_touchpoint, :action => :open, :first_time => params["first_time_open"], :email_open_number => params["opens_count"], :email_sent_time => email_sent_time)

            render json: {response: "email open posted", :status => 200}, status: 200
            return


        rescue
            render json: {error: "error - contact ScaleRep's tech department.", :status => 400}, status: 400
            return
        end
    end


    # API to catch all tags from front app. Adds a new campaign_reply object, and then updates the lead's status
    # API example payload: {"status": "auto_reply","last_conversation_subject": "Thank you for your email! Re: insurance question","email": "info@caninetherapycorps.org","last_conversation_summary": " Thank you so much for contacting Canine Therapy Corps! Your inquiry is important to us. We have a small staff, so please be patient. We will get back to you as soon as we can. If you do not receive a","full_name": "Canine Therapy Corps Inc."}
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

    # Check for empty post params
    def emptyPostParams(params)
        params.empty? ? true : false
    end

    # Never trust parameters from the scary internet,
    # only allow the white list through.
    def auto_reply_params
        @params_content.permit(:first_name, :last_name, :full_name, :last_conversation_subject, :last_conversation_summary, :email, :date_sourced, :status)
    end

    def email_sent_params
        @params_content.permit(:email_subject, :email_body, :sender_email, :channel, :lead, :campaign)
    end

    def get_reply_statuses
        return CampaignReply.statuses
    end

    def update_reply(field, value)
        @campaign_reply.update_attribute(field, value)
    end

    def update_lead(params_content, client_company, campaign_reply, status)

      @lead = Lead.where(["lower(email) = ? AND leads.client_company_id = ?", campaign_reply.email.downcase, client_company]).first

      if @lead.nil?
          
          if params_content[:full_name].split.length < 2
              f_name = @campaign_reply[:full_name]
              l_name = 'N/A'
          else
              f_name = @campaign_reply[:full_name].split[0...-1].join(" ").tr(",","")
              l_name = @campaign_reply[:full_name].split[-1]
          end

          new_lead = Lead.create!(:email => campaign_reply.email, :status => status, :full_name => params_content[:full_name], :first_name => f_name, :last_name => l_name, :client_company => client_company)
          campaign_reply.update_attribute(:lead, new_lead)

          if %w{handed_off sent_meeting_invite handed_off_with_questions}.include?(status)
            #campaign_reply.update_attribute(:date_sourced, Date.today)
            new_lead.update_attribute(:date_sourced, Date.today)
          end

          #check for first and last name
          
      else
              @lead.update_attribute(:status, status)
              campaign_reply.update_attribute(:lead, @lead)

              if %w{handed_off sent_meeting_invite handed_off_with_questions}.include?(status)
                    #campaign_reply.update_attribute(:date_sourced, Date.today)
                    @lead.update_attribute(:date_sourced, Date.today)
              end
      end
    end


end
