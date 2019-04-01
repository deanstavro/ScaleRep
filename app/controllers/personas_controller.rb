class PersonasController < ApplicationController
    before_action :authenticate_user!


    # GET /personas
    # GET /personas.json
    def index        
        
        #If admin, set client_companies chooser
        [@client_companies = scalerep_director_client_company()] if is_scalerep_admin

        #  If admin and company param exists, show company param's groups
        if is_scalerep_admin and params.has_key?(:client_company)
            @company = findCompanyByName(params["client_company"])
        else
            @company = current_user.client_company
        end

        @personas = @company.personas.order('created_at DESC')
        @current2 = @personas.where("archive =?", false)
        @archive2 = @personas.where("archive =?", true) 

        @current_sorted_metrics_array =  getPersonaMetrics(@current2).sort { |a, b| b[1] <=> a[1] }.paginate(:page => params[:page], :per_page => 20)
        @archive_sorted_metrics_array = getPersonaMetrics(@archive2).sort { |a, b| b[1] <=> a[1] }.paginate(:page => params[:page], :per_page => 20)
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
        @dropdown = Lead.statuses.keys

        if params[:search]
            @leads = @persona.leads.where('last_name LIKE ? OR first_name LIKE ? OR company_name LIKE ? OR email LIKE ?',"%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%").order(sort_column + " " + sort_direction).paginate(:page => params[:page], :per_page => 50)
        elsif params[:leadstatus]
            @leads = @persona.leads.where(status: params[:leadstatus]).order(sort_column + " " + sort_direction).paginate(:page => params[:page], :per_page => 50) 
        else
            @leads = @persona.leads.order(sort_column + " " + sort_direction).paginate(:page => params[:page], :per_page => 50)
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

    def getPersonaMetrics(personas)

        personas_array = []
        personas.each_with_index do |persona, index|
            # Get leads in the group
            lead_group_leads = persona.leads
            persona_array = [persona.id, lead_group_leads.handed_off.count + lead_group_leads.handed_off_with_questions.count, lead_group_leads.count, 0, 0, 0, 0, 0, persona.name ]
            # Find all Leads that have been contacted (or have a touchpoints associated with them)
            persona_array[3] = lead_group_leads.where('id IN (SELECT DISTINCT(lead_id) FROM touchpoints)').count
            #Total Touchpoints
            #persona_array[4] = lead_group_leads.joins(:touchpoints).count
            # Find number of leads Leads that have engaged (leads that have opened)
            persona_array[6] = lead_group_leads.where('id IN (SELECT DISTINCT(lead_id) FROM lead_actions)').count
            # Find number of leads who have replied
            persona_array[5] = LeadAction.where(lead: lead_group_leads, action: "reply").select(:lead_id).map(&:lead_id).uniq.count

            personas_array << persona_array
        end
        return personas_array
    end


    def sort_column
        Lead.column_names.include?(params[:sort]) ? params[:sort] : "full_name"
    end
  
    def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

end
