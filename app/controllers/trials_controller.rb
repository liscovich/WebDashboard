class TrialsController < ApplicationController
  before_filter :authenticate_researcher_or_player!
  
  def index
    @games = Game.order("created_at desc")
    @hero_unit_title = "Trials"
  end
end
