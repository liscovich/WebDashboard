class User
  include DataMapper::Resource
  property :id, Serial
  property :created_at, DateTime
  property :ip, String
  property :mid, Integer
  property :fake, Boolean

  has n, :gameusers
  has n, :games, :through=>:gameusers
end