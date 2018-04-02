class HomepageController < ApplicationController
  layout "homepage"

  def index

  	#ahoy.track_visit

  	if user_signed_in?
  		@user = current_user
  		redirect_to user_path(@user)
  	end
  end

  def agent
  end
  
end
