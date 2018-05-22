class HomepageController < ApplicationController
  layout "homepage"

  def index

  	#ahoy.track_visit
    puts "YOOOO"
  	if user_signed_in?
  		@user = current_user
      if @user.client_company.account_live == true
        puts "YES"
  		  redirect_to client_company_campaigns_path(@user.client_company)
      else
        redirect_to user_path(@user)
        puts "NO"

      end
    else
      @demo = Demo.new
  	end
  end

  
end
