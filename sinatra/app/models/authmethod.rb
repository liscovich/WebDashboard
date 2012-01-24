class Authmethod
	include DataMapper::Resource
	property :id, Serial
	property :created_at, DateTime
	property :auth_type, String, :unique_index=>[:u]
	property :auth_id, String, :unique_index=>[:u]

  property :user_id, Integer
	belongs_to :user

  def self.find_user_by_provider(provider,uid)
    am = first(:auth_type=>provider, :auth_id=>uid)
    am.nil? ? nil : am.user
  end

  def image_id
    h = {
      'mturk' => 'amazon',
      'facebook' => 'facebook'
    }
    h[self.auth_type]
  end
end