class HomeController < ApplicationController
  respond_to :html

  def show
    redirect '/trials' and return if logged_in?
    
    @hero_unit_title = "Welcome!"
    slim :"pages/signup"
  end
end
