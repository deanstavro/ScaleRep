class Api::V1::ReplyController < Api::V1::BaseController
  
    

    def auto_reply

        unless params[controller_name.to_s].empty?

            # grab reply params, with the json content
            @params_content = params[controller_name.to_s]
            
           begin
                # Create new lead with secured params
                @lead = Lead.new(auto_reply_params)
            rescue
                puts "wrong status"
                render json: {error: "Reply was not uploaded. Wrong status input.", :status => 400}, status: 400
                return
            end

            # Update lead to the correct company
            @client_company = ClientCompany.find_by(api_key: params["api_key"])
            update_lead(:client_company,@client_company)

            #Update lead status
            update_lead(:status, __method__.to_s)

            begin
                @lead.save!
                puts "saved"
                render json: {response: "Reply uploaded", :status => 200}, status: 200

            rescue
                puts "did not save"
                render json: {error: "Reply was not uploaded. E-mail required fields missing (email)", :status => 400}, status: 400
            end

        else
            puts "params empty"
            render json: {error: "Reply was not uploaded. JSON post parameters missing", :status => 400}, status: 400
        end

    end


    def new_reply
        
        unless params[controller_name.to_s].empty?

            # grab reply params, with the json content
            @params_content = params[controller_name.to_s]
            
            begin
                # Create new lead with secured params
                @lead = Lead.new(auto_reply_params)
            rescue
                puts "wrong status"
                render json: {error: "Reply was not uploaded. Wrong status input.", :status => 400}, status: 400
                return
            end

            # Update lead to the correct company
            @client_company = ClientCompany.find_by(api_key: params["api_key"])
            update_lead(:client_company,@client_company)




            if @params_content.key?(:status)

                #get all lead status enums
                statuses = get_lead_statuses

                for status in statuses

                    if status[0].to_s == @params_content[:status].to_s

                        puts "updating " + __method__.to_s
                        update_lead(:status, @params_content[:status].to_s)
                        puts "updated"
                        break
                    end
                    puts status[0]+ " not found"

                        
                end

            else
                puts "no status"
                render json: {error: "Reply was not uploaded. Please include status.", :status => 400}, status: 400
                return
            end


            begin
                @lead.save!
                puts "saved"
                render json: {response: "Reply uploaded", :status => 200}, status: 200
                return

            rescue
                puts "did not save"
                render json: {error: "Reply was not uploaded. E-mail required fields missing (email)", :status => 400}, status: 400
                return
            end

        else
            puts "params empty"
            render json: {error: "Reply was not uploaded. JSON post parameters missing", :status => 400}, status: 400
            return
        end


    end


    def referral
        unless params[controller_name.to_s].empty?

            # grab reply params, with the json content
            @params_content = params[controller_name.to_s]
            
            begin
                # Create new lead with secured params
                @lead = Lead.new(auto_reply_params)
            rescue
                puts "wrong status"
                render json: {error: "Reply was not uploaded. Wrong status input.", :status => 400}, status: 400
                return
            end

            # Update lead to the correct company
            @client_company = ClientCompany.find_by(api_key: params["api_key"])
            update_lead(:client_company,@client_company)

            #Update lead status
            update_lead(:status, __method__.to_s)

            begin
                @lead.save!
                puts "saved"
                render json: {error: "Reply uploaded", :status => 200}, status: 200

            rescue
                puts "did not save"
                render json: {error: "Reply was not uploaded. E-mail required fields missing (email)", :status => 400}, status: 400
            end

        else
            puts "params empty"
            render json: {error: "Reply was not uploaded. JSON post parameters missing", :status => 400}, status: 400
        end
    end


    def auto_reply_referral
        unless params[controller_name.to_s].empty?

            # grab reply params, with the json content
            @params_content = params[controller_name.to_s]
            
            begin
                # Create new lead with secured params
                @lead = Lead.new(auto_reply_params)
            rescue
                puts "wrong status"
                render json: {error: "Reply was not uploaded. Wrong status input.", :status => 400}, status: 400
                return
            end

            # Update lead to the correct company
            @client_company = ClientCompany.find_by(api_key: params["api_key"])
            update_lead(:client_company,@client_company)

            #Update lead status
            update_lead(:status, __method__.to_s)

            begin
                @lead.save!
                puts "saved"
                render json: {error: "Reply uploaded", :status => 200}, status: 200

            rescue
                puts "did not save"
                render json: {error: "Reply was not uploaded. E-mail required fields missing (email)", :status => 400}, status: 400
            end

        else
            puts "params empty"
            render json: {error: "Reply was not uploaded. JSON post parameters missing", :status => 400}, status: 400
        end
    end


    def not_interested
        unless params[controller_name.to_s].empty?

            # grab reply params, with the json content
            @params_content = params[controller_name.to_s]
            
            begin
                # Create new lead with secured params
                @lead = Lead.new(auto_reply_params)
            rescue
                puts "wrong status"
                render json: {error: "Reply was not uploaded. Wrong status input.", :status => 400}, status: 400
                return
            end

            # Update lead to the correct company
            @client_company = ClientCompany.find_by(api_key: params["api_key"])
            update_lead(:client_company,@client_company)

            #Update lead status
            update_lead(:status, __method__.to_s)

            begin
                @lead.save!
                puts "saved"
                render json: {error: "Reply uploaded", :status => 200}, status: 200

            rescue
                puts "did not save"
                render json: {error: "Reply was not uploaded. E-mail required fields missing (email)", :status => 400}, status: 400
            end

        else
            puts "params empty"
            render json: {error: "Reply was not uploaded. JSON post parameters missing", :status => 400}, status: 400
        end
    end


    def interested
        unless params[controller_name.to_s].empty?

            # grab reply params, with the json content
            @params_content = params[controller_name.to_s]
            
            begin
                # Create new lead with secured params
                @lead = Lead.new(auto_reply_params)
            rescue
                puts "wrong status"
                render json: {error: "Reply was not uploaded. Wrong status input.", :status => 400}, status: 400
                return
            end

            # Update lead to the correct company
            @client_company = ClientCompany.find_by(api_key: params["api_key"])
            update_lead(:client_company,@client_company)

            #Update lead status
            update_lead(:status, __method__.to_s)

            begin
                @lead.save!
                puts "saved"
                render json: {error: "Reply uploaded", :status => 200}, status: 200

            rescue
                puts "did not save"
                render json: {error: "Reply was not uploaded. E-mail required fields missing (email)", :status => 400}, status: 400
            end

        else
            puts "params empty"
            render json: {error: "Reply was not uploaded. JSON post parameters missing", :status => 400}, status: 400
        end
    end


    def do_not_contact
        unless params[controller_name.to_s].empty?

            # grab reply params, with the json content
            @params_content = params[controller_name.to_s]
            
            begin
                # Create new lead with secured params
                @lead = Lead.new(auto_reply_params)
            rescue
                puts "wrong status"
                render json: {error: "Reply was not uploaded. Wrong status input.", :status => 400}, status: 400
                return
            end

            # Update lead to the correct company
            @client_company = ClientCompany.find_by(api_key: params["api_key"])
            update_lead(:client_company,@client_company)

            #Update lead status
            update_lead(:status, __method__.to_s)

            begin
                @lead.save!
                puts "saved"
                render json: {error: "Reply uploaded", :status => 200}, status: 200

            rescue
                puts "did not save"
                render json: {error: "Reply was not uploaded. E-mail required fields missing (email)", :status => 400}, status: 400
            end

        else
            puts "params empty"
            render json: {error: "Reply was not uploaded. JSON post parameters missing", :status => 400}, status: 400
        end
    end


    private


    # Never trust parameters from the scary internet,
    # only allow the white list through.
    def auto_reply_params
        @params_content.permit(:first_name, :last_name, :full_name, :last_conversation_subject, :last_conversation_summary, :email, :date_sourced, :status)
    end
    
    def get_lead_statuses
        return Lead.statuses
    end

    def update_lead(field, value)
        @lead.update_attribute(field, value)
    end

end
