class Game < ActiveRecord::Base
  belongs_to :user

  has_many :gameusers
  has_many :users, :through => :gameusers
  has_many :events
  has_many :hits
  has_many :users, :through => :gameusers

  class << self
    def get_state_name(state)
      {
        'initialized' => 'Waiting for server...',
        'masterclient_started' => 'Waiting for players',
        'game_started' => 'Game in progress',
        'game_ended'   => 'Game over',
      }[state]
    end
  end

  def state_name
    self.class.get_state_name(self.state)
  end

  def ended?
    state == 'game_ended'
  end
end
