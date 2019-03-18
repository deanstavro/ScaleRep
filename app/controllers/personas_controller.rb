class PersonasController < ApplicationController
    before_action :authenticate_user!


    # GET /personas
    # GET /personas.json
    def index        
        
        #If admin, set client_companies chooser
        if is_scalerep_admin
            @client_companies = scalerep_director_client_company() 
        end

        #  If admin and company param exists, show company param's groups
        if is_scalerep_admin and params.has_key?(:client_company)
            @company = findCompanyByName(params["client_company"])
        else
            @company = current_user.client_company
        end

        @personas = @company.personas.order('created_at DESC')
        @current = @personas.where("archive =?", false).paginate(:page => params[:page], :per_page => 20)
        @archive = @personas.where("archive =?", true).paginate(:page => params[:page], :per_page => 20)

        #Get aggregates statistics for persona's campaigns
        @metrics_hash = getCampaignMetrics(@personas)
    end


    # GET /personas/new
    def new
        @persona = Persona.new

        if is_scalerep_admin
            @client_companies = scalerep_director_client_company()
        end

    end


    # POST /personas
    # POST /personas.json
    def create

        if is_scalerep_admin
            @company = ClientCompany.find_by(name: params[:persona][:client_company])
        else
            @company = ClientCompany.find_by(api_key: params[:persona][:client_company])
        end

        params[:persona].delete :client_company
        @persona = @company.personas.build(persona_params)

        respond_to do |format|
          if @persona.save
            format.html { redirect_to client_companies_personas_path, notice: 'Persona was successfully created.' }
            format.json { render :index, status: :created}
          else
            format.html { render :new }
            format.json { render json: @persona.errors, status: :unprocessable_entity }
          end
        end
    end


    # GET /personas/1/edit
    def edit
        @persona = Persona.find_by(id: params[:id])
        checkUserPrivileges(client_companies_personas_path, 'You cannot access this Lead Group')

    end

    def show
        @persona = Persona.find_by(id: params[:id])
        checkUserPrivileges(client_companies_personas_path, 'You cannot access this Lead Group')

        if params[:search]
            lead1 = @persona.leads.where(status: Lead.statuses[params[:search]])
            lead1 = [] if lead1.empty?
            lead2 = @persona.leads.where('last_name LIKE ? OR first_name LIKE ? OR company_name LIKE ? OR email LIKE ?',"%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%")
            lead2 = [] if lead2.empty?
            
            @leads = (lead1 + lead2).paginate(:page => params[:page], :per_page => 50)
        else
            @leads = @persona.leads.paginate(:page => params[:page], :per_page => 50)
        end
    end


    # PATCH/PUT /personas/1
    # PATCH/PUT /personas/1.json
    def update
        @persona = Persona.find_by(id: params[:id])
        checkUserPrivileges(client_companies_personas_path, 'You cannot access this Lead Group')

        respond_to do |format|
          if @persona.update(persona_params)
            format.html { redirect_to client_companies_personas_path, notice: 'Persona was successfully updated.' }
            format.json { render :index, status: :ok }
          else
            format.html { render :edit }
            format.json { render json: @persona.errors, status: :unprocessable_entity }
          end
        end
    end

    # PUT - update archive of a persona
    def archive
        @persona = Persona.find_by(id: params[:format])
        @persona.update_attribute(:archive, !@persona.archive)
        redirect_to client_companies_personas_path
    end

    
    # DELETE /personas/1
    # DELETE /personas/1.json
    def destroy
        @persona = Persona.find_by(id: params[:id])
        checkUserPrivileges(client_companies_personas_path, 'You cannot access this Lead Group')

        begin
            @persona.destroy
            respond_to do |format|
                format.html { redirect_to client_companies_personas_path, notice: 'Persona was successfully deleted' }
                format.json { head :no_content }
            end
        rescue
            respond_to do |format|
                format.html { redirect_to client_companies_personas_path, notice: 'Delete associated campaigns before deleting persona!' }
                format.json { head :no_content }
            end
        end
    end


    private


    # Never trust parameters from the scary internet, only allow the white list through.
    def persona_params
        params.require(:persona).permit(:name, :description, :special_instructions, :archive)
    end

    def findCompanyByName(params_client_company)
        return ClientCompany.find_by(name: params_client_company)
    end

    def checkUserPrivileges(path, message)
      if !is_scalerep_admin && @persona.client_company != current_user.client_company
        redirect_to path, notice: message
      end
    end

    def getCampaignMetrics(personas)

        metrics_hash = Hash.new
        personas.each do |persona|
            campaigns = persona.campaigns
            count = 0
            campaigns.each do |campaign|
                array = [campaign.peopleCount, campaign.deliveriesCount, campaign.bouncesCount, campaign.repliesCount, campaign.opensCount, campaign.uniqueOpens]
                count = count + 1
                if metrics_hash[persona]
                    metrics_hash[persona][0] += array[0].to_i
                    metrics_hash[persona][1] += array[1].to_i
                    metrics_hash[persona][2] += array[2].to_i
                    metrics_hash[persona][3] += array[3].to_i
                    metrics_hash[persona][4] += array[4].to_i
                    metrics_hash[persona][5] += array[5].to_i
                else
                    metrics_hash[persona] = array
                end
                metrics_hash[persona][6] = count
            end
        end
        return metrics_hash
    end


end
