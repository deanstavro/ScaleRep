class Api::V1::AccountController < Api::V1::BaseController

    def upload
        
        unless params["_json"].empty?

            # grab reply params, with the json content
            begin

                # grab reply params, with the json content
                @params_contents = params["_json"]

                for @params_content in @params_contents
                    puts "YOOOOOO"
                    puts "HERE"
                    puts @params_content
                    if @params_content.key?(:status)

                        #get all lead status enums
                        statuses = get_account_statuses

                        enum_count = 0
                        found = false
                        

                        for status in statuses
                            puts status

                            if status[0].to_s == @params_content[:status].to_s

                                puts "updating " + __method__.to_s
                                @params_content[:status] = enum_count
                                found = true
                                puts "updated"


                            else
                                enum_count = enum_count + 1
                                

                            end

                            
                        end
                        if found == false
                            @params_content[:status] = 0

                        end

                        #Update lead to the correct company
                        @client_company = ClientCompany.find_by(api_key: params["api_key"])
                        puts "YOLA"
                        puts @client_company
                        @params_content[:client_company_id] = @client_company.id


                    else
                        puts "No status found"
                        render json: {error: "Accounts not uploaded - no status field", :status => 400}, status: 400
                        return
                    end

                    begin
                        # Create new lead with secured params
                        @account = Account.create!(account_params)
                        puts "saved"

                    rescue
                        puts "Duplicate"


                    end


                end
                puts "done"
                render json: {response: "Accounts uploaded.", :status => 200}, status: 200
                return
            rescue
                puts "wrong status"
                render json: {error: "Accounts not uploaded - wrong json fields.", :status => 400}, status: 400
                return
            end

        end



    end


    def create
        
        unless params["account"].empty?

            # grab reply params, with the json content
            begin

                # grab reply params, with the json content
                @params_content = params["account"]

                if @params_content.key?(:status)

                    #get all lead status enums
                    statuses = get_account_statuses

                    enum_count = 0
                    found = false
                    

                    for status in statuses
                        puts status

                        if status[0].to_s == @params_content[:status].to_s

                            puts "updating " + __method__.to_s
                            @params_content[:status] = enum_count
                            found = true
                            puts "updated"


                        else
                            enum_count = enum_count + 1
                            

                        end

                        
                    end

                    #Update lead to the correct company
                    @client_company = ClientCompany.find_by(api_key: params["api_key"])
                    puts "YOLA"
                    puts @client_company
                    @params_content[:client_company_id] = @client_company.id

                    if found == false
                        render json: {error: "Accounts not uploaded - wrong status field", :status => 400}, status: 400
                        return

                    end

                else
                    puts "No status found"
                    render json: {error: "Accounts not uploaded - no status field", :status => 400}, status: 400
                    return
                end

                begin
                    # Create new lead with secured params
                    @account = Account.create!(account_params)
                    puts "saved"
                    render json: {response: "Account uploaded", :status => 200}, status: 200
                    return
                rescue
                    puts "Duplicate"
                    render json: {error: "Duplicate, or required fields (website, name, status) is missing", :status => 400}, status: 400
                    return

                end
            rescue
                puts "wrong status"
                render json: {error: "Accounts not uploaded - wrong json fields.", :status => 400}, status: 400
                return
            end

        end



    end




    def index

        begin
            # grab reply params, with the json content
            @params_content = params["account"]
            @account = Account.find_by!(website: params[:p1])

            render json: {response: @account, :status => 200}, status: 200
            return
        rescue
            puts "company dne"
            render json: {error: "Accounts does not exist", :status => 400}, status: 400
            return
        end



    end


    private


    # Never trust parameters from the scary internet,
    # only allow the white list through.
    def account_params
        @params_content.permit(:name, :client_company_id, :website, :status, :industry, :description, :internal_notes, :do_not_contact, :number_of_employees, :address, :city, :state, :country, :zipcode, :timezone, :last_funding_type, :last_funding_amount, :total_funding_raised, :last_funding_date)

    end

    def update_account(field, value)
        @account.update_attribute(field, value)
    end

    def get_account_statuses
        return Account.statuses
    end



end
