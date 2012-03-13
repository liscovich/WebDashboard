class EventsController < ApplicationController
  def index
    chain = if params[:debug]
      Event.all
    else
      game       = Game.find(params[:game_id])
      conditions = params[:id].blank? ? nil : ["id > ?", params[:id]]
      game.events.where(conditions)
    end

    events = chain.map{|e|
      {
        :id           => e.id,
        :game_id      => e.game_id,
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
end
