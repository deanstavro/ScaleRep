class TemplatesController < ApplicationController
	before_action :authenticate_user!

	def index
		@user = User.find(current_user.id)

		if @user.role == "scalerep"

            @client_companies = scalerep_director_client_company()
            if params.has_key?(:client_company)
                @company = ClientCompany.find_by(name: params["client_company"])
            else
				@company = ClientCompany.find(@user.client_company_id)
			end
		else
			@company = ClientCompany.find(@user.client_company_id)
		end

		@templates = @company.templates.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)

	end

	def new
		@user = User.find(current_user.id)
		@client_company = ClientCompany.find(@user.client_company_id)
		@template = Template.new
	end

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
   		if @template.destroy
  				redirect_to templates_path, notice: 'Template was successfully created.'
		end
   	end

   	
   	def edit
   		@template = Template.find(params[:id])
   	end

   	def update
   		@user = User.find(current_user.id)
		@client_company = ClientCompany.find_by(id: @user.client_company.id)
		@template = Template.find_by(id: params[:id])
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
      params.require(:template).permit(:title, :body)
    end
end

