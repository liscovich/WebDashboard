class LogsController < ApplicationController
  respond_to :json, :only => :index

  def index
    conditions = []
    values = []

    if params[:id]
      conditions << "id > ?"
      values << params[:id]
    end

    if params[:game_id]
      conditions << "game_id = ?"
      values << params[:game_id]
    end
    
    logs = conditions.any? ? Log.where([conditions.join(' AND '), *values]) : Log.all
    data = logs.map {|l|
      {
        :id       => l.id,
        :name     => l.name,
        :params   => l.parameters,
        :game_id  => l.game_id,
        :user_id  => l.user_id
      }
    }
    
    respond_with(data)
  end

  def delete_all
    Log.destroy_all
    redirect_to root_url, :notice => "All logs deleted!"
  end
end
