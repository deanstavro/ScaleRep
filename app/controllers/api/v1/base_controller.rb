class Api::V1::BaseController < ActionController::API
  
  # base_controller checks for API key of any
  # external service before parsing the request

  # Before validating the api_key, check for presence of api_key 
  # field passed by client, or return a 401
  before_action :check_authorization


  # Checks api_key field in json request passed by client
  def check_authorization
      unless params["api_key"].present? && check_api_key
          render json: {body: "Please provide a valid api key", :status => 401}, status: 401
      end
  end


  private

  # Check api key of any external service calling api/v1 route
  def check_api_key
      ClientCompany.exists?(api_key: params["api_key"])
  end

end