class HomepageController < ApplicationController
  layout "homepage"
  include Medium_News

  def index
        redirect_to new_user_session_path
  end

end
