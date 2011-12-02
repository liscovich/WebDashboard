class Event
  include DataMapper::Resource
  property :id, Serial
  property :created_at, DateTime
  property :eventtype, String

  property :state, Integer, :index=>true

  property :game_id, Integer, :index=>true
  property :user_id, Integer, :index=>true

  belongs_to :game
  belongs_to :user, :required=>false
end