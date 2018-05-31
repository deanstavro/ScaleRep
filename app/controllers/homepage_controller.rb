class HomepageController < ApplicationController
  layout "homepage"

  def index

  	#ahoy.track_visit

  	if user_signed_in?
  		@user = current_user
      if @user.client_company.account_live == true
        puts "Account Live - Direct to Persona Page"
  		  redirect_to client_company_campaigns_path(@user.client_company)
      else
        redirect_to user_path(@user)
        puts "Account Not Live - Direct to Onboarding"

      end
    else
        @demo = Demo.new
        puts "User not signed in - direct to home"
  	end
  end

  
end
