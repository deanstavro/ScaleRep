class DataUploadsController < ApplicationController
  before_action :set_data_upload, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /data_uploads
  # GET /data_uploads.json
  def index
    @user = User.find(current_user.id)
    @data_uploads = DataUpload.where("user_id =?", @user.id).order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
  end

  # GET /data_uploads/1
  # GET /data_uploads/1.json
  def show
      # Need data_upload.cleaned_data
      @user = User.find(current_user.id)
      @data_upload = DataUpload.find_by(id: params[:id])
      @campaign = @data_upload.campaign
      @client_company = @campaign.client_company
      @persona = @campaign.persona
      @headers = @data_upload.data[0].keys
      @cleaned_data = @data_upload.cleaned_data

      @values = []
      @cleaned_data.each do |value_hash|
        @values << value_hash.values
      end
  end

  # GET /data_uploads/new
  def new
    @data_upload = DataUpload.new
  end

  # GET /data_uploads/1/edit
  def edit
  end

  # POST /data_uploads
  # POST /data_uploads.json
  def create
    @data_upload = DataUpload.new(data_upload_params)

    respond_to do |format|
      if @data_upload.save
        format.html { redirect_to @data_upload, notice: 'Data upload was successfully created.' }
        format.json { render :show, status: :created, location: @data_upload }
      else
        format.html { render :new }
        format.json { render json: @data_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /data_uploads/1
  # PATCH/PUT /data_uploads/1.json
  def update
    respond_to do |format|
      if @data_upload.update(data_upload_params)
        format.html { redirect_to @data_upload, notice: 'Data upload was successfully updated.' }
        format.json { render :show, status: :ok, location: @data_upload }
      else
        format.html { render :edit }
        format.json { render json: @data_upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_uploads/1
  # DELETE /data_uploads/1.json
  def destroy
    @data_upload.destroy
    respond_to do |format|
      format.html { redirect_to data_uploads_url, notice: 'Data upload was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_data_upload
      @data_upload = DataUpload.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def data_upload_params
      params.fetch(:data_upload, {})
    end
end
