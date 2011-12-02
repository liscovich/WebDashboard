class Gameuser
  include DataMapper::Resource
  property :id, Serial
  property :game_id, Integer
  property :user_id, Integer

  belongs_to :game
  belongs_to :user
end