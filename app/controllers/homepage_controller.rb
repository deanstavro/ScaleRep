class HomepageController < ApplicationController
  layout "homepage"

  def index
        @demo = Demo.new
        puts "User not signed in - direct to home"
  end

  
end
