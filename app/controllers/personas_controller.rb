class PersonasController < ApplicationController
  #before_action :set_persona, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!


# GET /personas
# GET /personas.json
def index
  @user = User.find(current_user.id)
  if @user.role == "scalerep"
    @personas = Persona.order('created_at DESC')
    @current = @personas.where("archive =?", false).paginate(:page => params[:page], :per_page => 20)
    @archive = @personas.where("archive =?", true).paginate(:page => params[:page], :per_page => 20)

  else
    @company = ClientCompany.find_by(id: @user.client_company_id)
    @personas = Persona.where("client_company_id =?", @company).order('created_at DESC')
    @current = @personas.where("archive =?", false).paginate(:page => params[:page], :per_page => 20)
    @archive = @personas.where("archive =?", true).paginate(:page => params[:page], :per_page => 20)
  end

    @metrics_hash = Hash.new
    @personas.each do |persona|

        @campaigns = persona.campaigns
        count = 0
        @campaigns.each do |campaign|
            array = [campaign.peopleCount, campaign.deliveriesCount, campaign.bouncesCount, campaign.repliesCount, campaign.opensCount]
            count = count + 1
            if @metrics_hash[persona]
              @metrics_hash[persona][0] = @metrics_hash[persona][0].to_i + array[0].to_i
              @metrics_hash[persona][1] = @metrics_hash[persona][1].to_i + array[1].to_i
              @metrics_hash[persona][2] = @metrics_hash[persona][2].to_i + array[2].to_i
              @metrics_hash[persona][3] = @metrics_hash[persona][3].to_i + array[3].to_i
              @metrics_hash[persona][4] = @metrics_hash[persona][4].to_i + array[4].to_i

              # add
            else
              @metrics_hash[persona] = array
            end

            @metrics_hash[persona][5] = count

          end

        # Aggregate the metrics here
        for metrics in @metrics_hash
          for fields in metrics
            puts fields
          end
        end
      end
  end




  # GET /personas/1
  # GET /personas/1.json
  #def show
  #end

  # GET /personas/new
  def new
    @user = User.find(current_user.id)
    @persona = Persona.new

    puts "hi can you see this?"
  end

  # GET /personas/1/edit
  def edit
    @user = User.find(current_user.id)
    @client_company = ClientCompany.find_by(id: @user.client_company_id)
    @persona = Persona.find_by(id: params[:id])
  end

  def archive
    @user = User.find(current_user.id)
    @company = ClientCompany.find_by(id: @user.client_company_id)
    @persona = Persona.find_by(id: params[:format])

    # update archive setting
    @persona.update_attribute(:archive, !@persona.archive)
    redirect_to client_companies_personas_path

  end

  # POST /personas
  # POST /personas.json
  def create
    @user = User.find(current_user.id)
    @company = ClientCompany.find_by(id: @user.client_company_id)
    @persona = Persona.new(persona_params)
    @persona.client_company = @company


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

  # PATCH/PUT /personas/1
  # PATCH/PUT /personas/1.json
  def update
    puts "PERSONA PARAMS"

    @user = User.find(current_user.id)
    @persona = Persona.find_by(id: params[:id])

    puts persona_params

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

  # DELETE /personas/1
  # DELETE /personas/1.json
  def destroy
    persona = Persona.find_by(id: params[:id])

    begin

        persona.destroy
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


    # Use callbacks to share common setup or constraints between actions.
    def set_persona
      @persona = Persona.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def persona_params
      params.require(:persona).permit(:name, :description, :special_instructions, :archive)
    end
end
