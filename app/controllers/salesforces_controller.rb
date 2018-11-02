class SalesforcesController < InheritedResources::Base
  require 'restforce'
  include Salesforce_Integration
  
  def index
  	@user = find_current_user(current_user.id)
  	@client_company = @user.client_company
  	@client_company_id = @user.client_company.id
  	@salesforce = @client_company.salesforce
  	@pages = ["options", "duplicates", "fields"]

  	if @salesforce.nil?
  		@salesforce = Salesforce.new()
  	end
  end


  def create
  	@salesforce = Salesforce.new(salesforce_params)

  	respond_to do |format|
	    if @salesforce.save

	      sf_obj = authenticate(@salesforce)

	      if sf_obj != 400

	      		  @salesforce.update_attribute(:salesforce_integration_authorized, true)

			      format.html  { redirect_to(salesforces_path,
			                    :notice => 'Salesforce Authorized! Integration Complete.') }
			      format.json  { render :json => @salesforce,
			                    :status => :created, :location => @salesforce }
		  else

		  		  @salesforce.update_attributes(:salesforce_integration_authorized => false, :salesforce_integration_on => false )

		  		  format.html  { redirect_to(salesforces_path,
			                    :notice => 'Error!') }
			      format.json  { render :json => @salesforce,
			                    :status => :created, :location => @salesforce }
		  end
	    else

	      @salesforce.update_attributes(:salesforce_integration_authorized => false, :salesforce_integration_on => false )

	      format.html  { redirect_to(salesforces_path) }
	      format.json  { render :json => @salesforce.errors,
	                    :status => :unprocessable_entity }
	    end
  	end
  end


  def update
  	@salesforce = Salesforce.find_by(id: params["id"])

  	respond_to do |format|
	    if @salesforce.update_attributes(salesforce_params)
	      sf_obj = authenticate(@salesforce)
	      if sf_obj != 400
	      		  @salesforce.update_attribute(:salesforce_integration_authorized, true)

			      format.html  { redirect_to(salesforces_path,
			                    :notice => 'Salesforce Authorized! Update Complete.') }
			      format.json  { render :json => @salesforce,
			                    :status => :created, :location => @salesforce }
		  else
		  		  @salesforce.update_attributes(:salesforce_integration_authorized => false, :salesforce_integration_on => false )
		  		  format.html  { redirect_to(salesforces_path,
			                    :notice => 'Error!') }
			      format.json  { render :json => @salesforce,
			                    :status => :created, :location => @salesforce }
		  end
	    else
	      @salesforce.update_attributes(:salesforce_integration_authorized => false, :salesforce_integration_on => false )

	      format.html  { redirect_to(salesforces_path) }
	      format.json  { render :json => @salesforce.errors,
	                    :status => :unprocessable_entity }
	    end
  	end


  end


  def toggle
  	@salesforce = Salesforce.find_by(id: params[:id])
 	@salesforce_option = @salesforce.salesforce_integration_on
 	@salesforce.update_attribute(:salesforce_integration_on, !@salesforce_option)

 	redirect_back(fallback_location: root_path)
  end



  private

	def salesforce_params
	  params.require(:salesforce).permit(:api_version, :username, :password, :security_token, :app_key, :app_secret, :client_company_id, :upload_contacts_to_salesforce_option, :check_dup_against_existing_contact_email_option, :check_dup_against_existing_account_domain_option)
	end

end

