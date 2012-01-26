class Games::UsersController < ApplicationController
  respond_to :json#, :only => :index

  before_filter :find_game

  def earnings
    gu = @game.gameusers.where(:user_id => params[:user_id]).first

    #TODO stupid hack?
    data = if gu.nil? or gu.final_score.nil?
      [0]
    else
      [1, display_decimal(2,gu.final_score * gu.game.exchange_rate)]
    end

    respond_with(data)
  end

  def record_submission
    gu = @game.gameusers.where(:user_id => params[:user_id]).first

    #TODO stupid hack?
    data = if gu.nil? or gu.final_score.nil?
      [0]
    else
      gu.update_attribute :mturk, false
      [1]
    end

    respond_with(data)
  end

  def pay
    gu = @game.gameusers.find(params[:id])
    gu.approve!
    
    redirect_to root_path, :notice => "You paid #{gu.user.get_name}!"
  end

  private

  def find_game
    @game = Game.find(params[:game_id])
  end
end
