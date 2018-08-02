class CampaignController < ApplicationController
  before_action :authenticate_user!
	require 'rest-client'
	require 'json'
	include Reply

  def index

  end

  def show
    # print params

    # get campaign and go to reply API
    @campaign = get_campaign(params)

    # execute reply api
    # TODO: move this to a job
    sequence = get_sequence(@campaign)

    # go through and format necessary inforation
    @sequence_array = []
    for count in 0..sequence.length-1 do
      step = {
        'number'  => sequence[count][:number].to_i,
        'day'     => sequence[count][:inMinutesCount]/60/24.to_i,
        'subject' => sequence[count][:templates][0][:subject],
        'body'    => sequence[count][:templates][0][:body]
      }
      @sequence_array.push(step)
    end

  end

  def edit
  end


  private
  def get_campaign(id)
    return Campaign.find_by(id: params[:id])
  end

  def get_sequence(campaign)
    # craft Request
    # TODO: error check

    response = RestClient.get(
      "https://api.reply.io/v2/campaigns/#{campaign.reply_id}/steps",
      {:'X-Api-Key' => "#{campaign.reply_key}"}
    )

    response = JSON.parse(response, symbolize_names: true)
  end

  # reply_api grab data
end
