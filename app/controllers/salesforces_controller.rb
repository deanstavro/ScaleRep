class SalesforcesController < InheritedResources::Base
  require 'restforce'
  include Salesforce_Integration
  
  # GET - Renders Salesforce Settings Page
  # Renders client_company's salesforce if it exist. Or renders a new salesforce
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

  # GET, POST - Salesforce authentication error - redirect to salesforce_path
  def failure
  	redirect_to(salesforces_path)
  end

  # Sets Up Salesforce web-server login
  # Grabs saved app_key and app_secret
  # Redirects to the salesforce page
  def setup
 	begin
	 	@user = find_current_user(current_user.id)
	  	@client_company = @user.client_company
	  	@salesforce = @client_company.salesforce
	  	app_key = @salesforce.app_key
	  	app_secret = @salesforce.app_secret
	  	puts "APP KEYS: " + app_key + "  " + app_secret
	    req = request.env['omniauth.strategy'].options.merge!({ client_id: app_key, client_secret: app_secret })
	    redirect_to(salesforces_path)
	rescue
		redirect_to(salesforces_path,:error => 'ERROR. Your credentials are correct, but check you Salesforce App settings')
	end
  end

  def web_authentication
  	@user = find_current_user(current_user.id)
	@client_company = @user.client_company
	
	begin
		@salesforce = @client_company.salesforce
		puts  env["omniauth.auth"].to_s
	  	puts env["omniauth.auth"].credentials.instance_url.to_s
	  	puts env["omniauth.auth"].credentials.token.to_s
	  	puts env["omniauth.auth"].credentials.refresh_token.to_s
	  	@salesforce.update_attributes(:instance_url => env["omniauth.auth"].credentials.instance_url, :oauth_token => env["omniauth.auth"].credentials.token , :refresh_token => env["omniauth.auth"].credentials.refresh_token )
 		@salesforce.update_attributes(:salesforce_integration_authorized => true, :salesforce_integration_on => false)
 		if authenticate(@salesforce) != 400
	    	redirect_to(salesforces_path, :notice => "you are now integrated with Salesforce. Turn your integration ON!")
	    else
	    	redirect_to(salesforces_path, :notice => "Able to connect, but not authenticate. Error")
	    end
	rescue
		redirect_to(salesforces_path,:error => 'Incorrect app_key/app_secret. Please try again')
		@salesforce.update_attributes(:salesforce_integration_authorized => false, :salesforce_integration_on => false )
	end
  end



  def create
  	@salesforce = Salesforce.new(salesforce_params)
    if @salesforce.save
      redirect_to '/auth/salesforce'
	else
	  redirect_to(salesforces_path, :notice => 'Error! Refresh and try again')
	end
  end


  def update
  	@salesforce = Salesforce.find_by(id: params["id"])
    if @salesforce.update_attributes(salesforce_params)
      if params["salesforce"]["app_key"] or params["salesforce"]["app_key"]
      	  @salesforce.update_attributes(:salesforce_integration_authorized => false, :salesforce_integration_on => false )
      	  redirect_to '/auth/salesforce'
      else
      	redirect_to(salesforces_path, :notice => 'Salesforce Options Updated!')
	  end
    else
      @salesforce.update_attributes(:salesforce_integration_authorized => false, :salesforce_integration_on => false )
      redirect_to(salesforces_path)
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
	  params.require(:salesforce).permit(:api_version, :username, :password, :security_token, :app_key, :app_secret, :client_company_id, :upload_contacts_to_salesforce_option, :check_dup_against_existing_contact_email_option, :check_dup_against_existing_account_domain_option, :upload_accounts_to_salesforce_option)
	end

end