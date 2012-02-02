class EventsController < ApplicationController
  respond_to :json, :only => :index

  before_filter :find_game

  def index
    events = Event.where(["id > ?", params[:id]]).map{|e|
      {
        :id           => e.id,
        :user_id      => e.user_id,
        :event_type   => e.event_type,
        :state        => e.state,
        :state_name   => (e.state.nil? ? nil : Game.get_state_name(e.state)),
        :choice       => e.choice,
        :round_id     => e.round_id,
        :total_score  => e.total_score,
        :is_ai        => e.is_ai,
        :ai_id        => e.ai_id,
        :score        => e.score
      }.reject{|k,v| v.nil? }
    }.compact

    respond_with(events)
  end

  private

  def find_game
    @game = Game.find(params[:game_id])
  end
end
