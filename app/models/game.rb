class Game
  include DataMapper::Resource
  property :id, Serial
  property :created_at, DateTime
  property :gameid, String
  property :state, String, :default=>'initialized'

  property :title, String
  property :description, Text

  property :totalplayers, Integer
  property :humanplayers, Integer
  property :numplayers, Integer

  property :contprob, Decimal, :scale=>2
  property :init_endow, Integer
  property :cost_defect, Integer
  property :cost_coop, Integer
  property :ind_payoff_shares, Decimal, :scale=>2

  property :hit_id, String, :length=>100
  property :rturk_url, String, :length=>100
  
  property :approved, Boolean, :default=>false
    
  has n, :gameusers
  has n, :hits
  has n, :users, :through=>:gameusers

  def state_name
    h = {
      'initialized' => 'Waiting for server...',
      'masterclient_started' => 'Waiting for players',
      'game_started' => 'Game in progress',
      'game_ended' => 'Game over',
    }
    h[self.state]
  end
end