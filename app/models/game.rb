class Game < ActiveRecord::Base
  belongs_to :user
  belongs_to :experiment

  has_many :gameusers
  has_many :users, :through => :gameusers
  has_many :events
  has_many :hits

  [:title, :contprob, :init_endow, :cost_defect, :cost_coop, :ind_payoff_shares, :exchange_rate, :totalplayers, :humanplayers].each do |attr|
    default_values attr => lambda{|g| g.experiment.send(attr)}
  end

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

  def set_state!(new_state)
    update_attributes! :state => new_state
  end

  def ended?
    state == 'game_ended'
  end

  def post_mturk!(redirect_url)
    WindowsServer.start_master_client!(self)

    humanplayers.times do
      #TODO refactor
      hitt = RTurk::Hit.create(:title => "Come play a card game!") do |hit|
        hit.hit_type_id = HIT_TYPE.type_id
        hit.assignments = 1
        hit.description = "More card games!"
        hit.question("http://card.demo.s3.amazonaws.com/frame.html?redirect_url=#{redirect_url}", :frame_height => 1000)
        hit.keywords = 'card, game, economics'
        hit.reward = 0.01
        hit.lifetime = 240
        hit.duration = 240
      end

      hits.create!(:hitid => hitt.id, :url => hitt.url)
    end
  end
end
