class HomepageController < ApplicationController
  layout "homepage"

  def index
  	ahoy.track_visit

  	if user_signed_in?
  		redirect_to users_path
  	end
  end

  def agent
  end
  
end
