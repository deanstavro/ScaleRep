class DataUploadsController < ApplicationController
  before_action :set_data_upload, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  include Reply
  require 'will_paginate/array'

  # GET /data_uploads
  # GET /data_uploads.json
  def index
    @user = User.find(current_user.id)
    @data_uploads = DataUpload.where(["user_id = ?", @user.id]).order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
    @data_uploads.each do |value_hash|
      puts value_hash.id.to_s
    end
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

    #hidden fields
    @per_page = 150
    @page = params[:page]
    @page_results = @values.paginate(:page => @page, :per_page => @per_page)
  end


  # GET /data_uploads/show_data_list - Shows Upload Data Lists (Imported, Not Imported, CRM Dups, Cleaned, Uploaded)
  def show_data_list
    @user = User.find(current_user.id)
    @data_upload = DataUpload.find_by(id: params[:id])
    @headers = @data_upload.data[0].keys
    @campaign = @data_upload.campaign
    @client_company = @campaign.client_company
    
    @list_name = params[:list]
    @list_unpa = @data_upload.method(params[:list]).call
    @list_unpa.each_with_index do |record, index|
      @list_unpa[index] = record.slice(*@headers)
    end
    @list = @list_unpa.paginate(:page => params[:page], :per_page => 100)
  end

  # GET /data_uploads/new
  def new
    @data_upload = DataUpload.new
  end

  # GET /data_uploads/1/edit
  def edit
    @user = User.find(current_user.id)
    @campaign = Campaign.find_by(id: @data_upload.campaign)
    @persona = @campaign.persona
    @headers = @data_upload.headers.tr('[]"', '').split(',').map(&:to_s)
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
    @user = User.find(current_user.id)
    @campaign = Campaign.find_by(id: @data_upload.campaign)
    @client_company = @campaign.client_company
    rules_array = params[:data_upload][:rules].split(",/")
    params[:data_upload].delete :rules
    
    if  @data_upload.update_attributes(secure_params)
        
        @data_upload.update_attribute(:rules, rules_array)
        
        CleanUploadJob.perform_later(@data_upload, @client_company)
        redirect_to data_upload_path(:id => @data_upload.id), :flash => { :notice => "Contacts are being saved and uploaded. Wait and refresh. This task should only take a couple seconds!" }
        return
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



  # CSV upload initiated by user on the campaign
  # Uploads CSV, and created a DataUpload object.
  # Redirects to leads#import for clean options
  def campaign_data
    # User account we are logged into
    user = User.find(current_user.id)
    persona = Persona.find_by(id: params[:persona].to_i)
    campaign = Campaign.find_by(id: params[:campaign].to_i)
    company = campaign.client_company
    leads = Lead.where(client_company: company)
    col =  Lead.column_names - %w{id client_company_id campaign_id account_id}
    # Column Names
    # ["decision_maker", "internal_notes", "email_in_contact_with", "date_sourced", "created_at", "updated_at", "contract_sent", "contract_amount", "timeline", "project_scope", "email_handed_off_too", "meeting_time", "email", "first_name", "last_name", "hunter_score", "hunter_date", "title", "phone_type", "phone_number", "city", "state", "country", "linkedin", "timezone", "address", "meeting_taken", "full_name", "status", "company_name", "company_website"]
    begin
        if (params[:file].content_type).to_s == 'text/csv'
          if (params[:file].size).to_i < 1000000
            upload_message, uploaded_data = DataUpload.campaign_data_upload(params[:file], company, campaign, col, user)
            puts "Finished uploading. Redirecting!"
            # If error in upload (because of duplicate columns, or columns missing)
            if uploaded_data.nil?
              redirect_to client_companies_campaigns_path(persona), :flash => { :error => upload_message }
              return
            else
              flash[:notice] = upload_message
              redirect_to edit_data_upload_path(uploaded_data.id)
            end
          else

            redirect_to client_companies_campaigns_path(persona), :flash => { :error => "The CSV is too large. Please upload a shorter CSV!" }
            return
          end
        else
          redirect_to client_companies_campaigns_path(persona), :flash => { :error => "The file was not uploaded. Please Upload a CSV!" }
          return
        end
    rescue
        redirect_to client_companies_campaigns_path(persona), :flash => { :error => "No file chosen. Please upload a CSV!" }
        return
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

    def secure_params
      params.require(:data_upload).permit(:ignore_duplicates, :rules)
    end
end
