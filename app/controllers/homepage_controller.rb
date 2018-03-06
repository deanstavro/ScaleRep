class HomepageController < ApplicationController
  layout "homepage"

  def index
  	ahoy.track_visit
  end

  def agent
  end
  
end
