class Api::V1::MetricsController < Api::V1::BaseController

  # CampaignsController - post campaigns to Calltend system


  # api/v1/all_metrics - POST campaign to calltend system
  # Required Fields:

  def all_metrics

  @client_company = ClientCompany.find_by(api_key: params[:api_key])


  puts @client_company.name
  puts "all_metrics completed"


  end


  private


end
