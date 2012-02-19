class Event < ActiveRecord::Base
  belongs_to :game
  belongs_to :user

  after_create :update_game_status

  private

  def update_game_status
    return unless event_type == 'gamestate_update'

    game.set_state!(state)
  end
end
