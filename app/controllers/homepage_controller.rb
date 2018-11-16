class HomepageController < ApplicationController
  layout "homepage"
  include Medium_News

  def index
        @demo = Demo.new
        puts "User not signed in - direct to home"
  end

end
