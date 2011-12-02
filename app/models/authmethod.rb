class Authmethod
	include DataMapper::Resource
	property :id, Serial
	property :created_at, DateTime
	property :auth_type, String
	property :auth_id, String

  property :user_id, Integer
	belongs_to :user
end