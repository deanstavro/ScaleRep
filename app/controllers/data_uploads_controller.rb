class DataUploadsController < ApplicationController
  before_action :set_data_upload, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  include Reply
  require 'will_paginate/array'
  include DataUploadsHelper

  
  # CSV upload initiated by user on the campaign
  # Uploads CSV, and created a DataUpload object.
  # Redirects to leads#import for clean options
  def create
    # User account we are logged into
    persona = Persona.find_by(id: params[:persona].to_i)
    campaign = Campaign.find_by(id: params[:campaign].to_i)
    leads = Lead.where(client_company: campaign.client_company)
    # Check Data Upload Requirements
    can_upload, message = DataUpload.pass_upload_requirements(params[:file])
    # If File can be uploaded, proceed
    if can_upload
      #Upload Data
      upload_message, uploaded_data = upload_data(params[:file], campaign.client_company, campaign)
      # If file is empty
      if uploaded_data.nil?
        redirect_to client_companies_campaigns_path(persona), :flash => { :error => upload_message }
      else
        redirect_to edit_data_upload_path(uploaded_data.id), :flash => { :notice => upload_message }
      end
    else
      redirect_to client_companies_campaigns_path(persona), :flash => { :error => message }
    end
  end

  # Edit the data upload with rules
  def edit
    @campaign = Campaign.find_by(id: @data_upload.campaign)
    @persona = @campaign.persona
    @headers = @data_upload.headers.tr('[]"', '').split(',').map(&:to_s)
  end

  # Update Data Upload Based on Rules
  def update
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

  # Show that data upload
  # Allow user to edit contents 1 by 1
  def show
    @data_upload = DataUpload.find_by(id: params[:id])
    @campaign = @data_upload.campaign
    @client_company = @campaign.client_company
    @headers = @data_upload.data[0].keys
    @cleaned_data = @data_upload.cleaned_data
    
    @values = []
    @cleaned_data.each do |value_hash|
      @values << value_hash.values
    end

    #keep params to be passed into update_cleaned_data
    @page = params[:page]
    @per_page = 150
    @page_results = @values.paginate(:page => @page, :per_page => @per_page)
  end

  # POST, Reclean data, and show STEP 3 page, the page rendered after rules and inputted data cleaned
  def update_cleaned_data
    @data_upload = DataUpload.find_by(id: params[:data_upload])
    @per_page = params[:per_page].to_i

    if params[:page].empty?
      @page = 1
    else
      @page = params[:page].to_i
    end
    clean_import_data(@data_upload, @page, 150)
    redirect_to data_upload_path(:id => @data_upload.id), :flash => { :notice => "Your changes have been saved. Click '+ import to campaign' to add to the the list to the campaign!" }
  end

  # GET /data_uploads
  # GET /data_uploads.json
  def index
    @user = User.find(current_user.id)
    @data_uploads = DataUpload.where(["user_id = ?", @user.id]).order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
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

  # Loops through a file. Checks if first_name and email are present
  # Save Data_Upload object with data as a hash
  def upload_data(file, company, campaign)
    # Check if keys are correct according to Data Upload method
    keys_array, keys_unused, data, count = DataUpload.check_default_rules_of_uploaded_csv(file)

    new_data_upload = DataUpload.create(client_company: company, campaign: campaign, user: current_user, data: data, count: count, headers: keys_array.to_s)
    return count.to_s + " records uploaded. Columns " + keys_array.to_s + " included.", new_data_upload
  end

end
