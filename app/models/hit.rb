class Hit
  include DataMapper::Resource
  property :id, Serial
  property :url, String, :length=>100
  property :hitid, String
  property :sandbox, Boolean
  property :game_id, Integer
    
  belongs_to :game
end