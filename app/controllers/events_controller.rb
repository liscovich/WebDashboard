class EventsController < ApplicationController
  before_filter :find_game, :only => :index

  def index
    events = @game.events.where(["id > ?", params[:id]]).map{|e|
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
        :score        => e.score,
        :extra        => e.extra
      }.reject{|k,v| v.nil? }
    }.compact

    render :json => events
  end

  def create
    e = Event.new(params[:event])
    if e.save
      render :json => {:status => 'ok'}
    else
      render :json => {:status => 'record invalid', :errors => e.errors.full_messages}
    end
  end

  private

  def find_game
    @game = Game.find(params[:game_id])
  end
end
