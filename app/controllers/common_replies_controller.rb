class CommonRepliesController < ApplicationController
    
  
  def index
    @user = User.find(current_user.id)
    # ScaleRep Admin has the ability to choose replies by company
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

    @common_replies = @company.common_replies.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
  end

  
  def new
    @user = User.find(current_user.id)
    @client_company = ClientCompany.find_by(id: params[:company_id])
    @common_reply = CommonReply.new
  end

  
  def create
      @user = User.find(current_user.id)
      @company_id = params[:common_reply][:client_company]
      @client_company = ClientCompany.find_by(id: @company_id)

      @common_reply = @client_company.common_replies.build(common_reply_params)

      respond_to do |format|
          if @common_reply.save
              format.html { redirect_to common_replies_path(), notice: 'Reply was successfully created.' }
              format.json { render :index, status: :created}
          else
              format.html { render :new }
              format.json { render json: @common_reply.errors, status: :unprocessable_entity }
          end
      end
  end

  
  def edit
    @common_reply = CommonReply.find(params[:id])
  end

  
  def update
      @user = User.find(current_user.id)
      @client_company = ClientCompany.find_by(id: @user.client_company.id)
      @common_reply = CommonReply.find_by(id: params[:id])
      respond_to do |format|
        if @common_reply.update(common_reply_params)
          format.html { redirect_to common_replies_path(), notice: 'Reply was successfully updated' }
          format.json { render :index, status: :created}
        else
          format.html { render :update }
          format.json { render json: @template.errors, status: :unprocessable_entity }
        end
      end
  end

  
  def destroy
    @common_reply = CommonReply.find(params[:id])
      if @common_reply.destroy
          redirect_to common_replies_path, notice: 'Reply was successfully deleted.'
      end
  end

  
  private

  def common_reply_params
      params.require(:common_reply).permit(:name, :common_message, :reply_message)
    end
end
