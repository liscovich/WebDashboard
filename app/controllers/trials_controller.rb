class TrialsController < ApplicationController
  before_filter :login_required
  
  def index
    @games = Game.order("created_at desc")
    @hero_unit_title = "Trials"
  end
end
