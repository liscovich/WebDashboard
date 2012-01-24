class Log
  include DataMapper::Resource
  property :id, Serial
  property :created_at, DateTime
  property :name, String
  property :parameters, Json

  property :userid, String
  property :gameid, String
  
  property :user_id, String
  property :game_id, String

  belongs_to :user, :required=>false
end