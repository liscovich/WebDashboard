Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
#  provider :facebook, '298008136906418', 'eba849e808cf4d6b71fd37d32362d5ba', { :scope => 'status_update, publish_stream, offline_access' }
#  #provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp')
  provider :twitter, 'I59w2LJV2VwGkk7TgGpXMg', 'wtx6Kub9VoxdN3gFeM5s7bm182rWWGMJwDslS76WI'
end