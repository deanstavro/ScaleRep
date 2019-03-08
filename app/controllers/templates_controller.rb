class TemplatesController < ApplicationController
	before_action :authenticate_user!


  # Display all templates per company
	def index
    # ScaleRep Admin has the ability to choose templates by company
		if is_scalerep_admin
        @client_companies = client_companies()
        
        if params.has_key?(:client_company)
            @company = getCompanyByName(params["client_company"])
        else
				  @company = current_user.client_company
			  end
		else
			  @company = current_user.client_company
		end
		@templates = @company.templates.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
	end


  # Displays new form to create template
  # Company Id parameter passed in from index page
	def new
		@client_company = ClientCompany.find_by(api_key: params[:company_api_key])
		@template = Template.new
	end


  # Create new template 
	def create
		  @user = User.find(current_user.id)
		  @company_id = params[:template][:client_company]
		  @client_company = ClientCompany.find_by(id: @company_id)

      @template = @client_company.templates.build(template_params)

      respond_to do |format|
          if @template.save
              format.html { redirect_to templates_path(), notice: 'Template was successfully created.' }
              format.json { render :index, status: :created}
          else
              format.html { render :new }
              format.json { render json: @template.errors, status: :unprocessable_entity }
          end
      end
	end


	def destroy
		  @template = Template.find(params[:id])
      checkUserPrivileges(templates_path, 'You cannot access this template')

      if @template.destroy
  				redirect_to templates_path, notice: 'Template was successfully created.'
		  end
   end

   	
  def edit
   	  @template = Template.find(params[:id])

      checkUserPrivileges(templates_path, 'You cannot access this template')
  end


  def update
	    
      @template = Template.find_by(id: params[:id])

      checkUserPrivileges(templates_path, 'You cannot access this template')

      respond_to do |format|
        if @template.update(template_params)
          format.html { redirect_to templates_path(), notice: 'Template was successfully updated' }
          format.json { render :index, status: :created}
        else
          format.html { render :update }
          format.json { render json: @template.errors, status: :unprocessable_entity }
        end
      end
  end


  private

    def template_params
      params.require(:template).permit(:title, :body, :subject)
    end

    def client_companies()
      client_companies = ClientCompany.where("account_live = ?", true).pluck(:name)
      return client_companies
    end

    def getCompanyByName(company_name)
      return ClientCompany.find_by(name: company_name)
    end

    def checkUserPrivileges(path, message)
      if !is_scalerep_admin && @template.client_company != current_user.client_company
        redirect_to path, notice: message
      end
    end

end

