class Event
  include DataMapper::Resource
  property :id, Serial
  property :created_at, DateTime

  property :state, String
  property :round_id, Integer
  
  property :score, Integer
  property :total_score, Integer
  property :event_type, String

  property :choice, String
  
  property :game_id, Integer, :index=>true
  property :user_id, Integer, :index=>true

  property :is_ai, Boolean
  property :ai_id, String

  property :extra, String

  belongs_to :game
  belongs_to :user, :required=>false
end