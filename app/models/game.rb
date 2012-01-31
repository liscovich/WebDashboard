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

  def post_mturk!(redirect_url)
    uri = URI("http://#{WINDOWS_SERVER_IP}/new")
    param = "-session=#{id} -server=#{WINDOWS_IP}:#{WINDOWS_PHOTON_PORT} -totalPlayers=#{totalplayers} -humanPlayers=#{humanplayers} -probability=#{contprob} -initialEndowments=#{init_endow} -payout=#{ind_payoff_shares} -cardLowValue=#{cost_defect} -cardHighValue=#{cost_coop} -exchangeRate=#{exchange_rate} -batchmode"

    res = Net::HTTP.post_form(uri, 'id' => id, 'instance' => 'test', 'args' => param)

    unless res.code == "200"
      destroy
      p res.body
      return res.body
      #flash_back "Cannot not start up master client!"
    end

    #uri = URI("http://#{WINDOWS_SERVER_IP}/instance/#{g.id}.unity3d")
    #res = Net::HTTP.get(uri)

    #File.open(ROOT+"/../public/flash/webplayer.unity3d", "wb") do |file|
    #  file.write(res)
    #end

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
