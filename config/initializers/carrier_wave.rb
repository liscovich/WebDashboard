CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider           => 'Rackspace',
    :rackspace_username => 'hcplab',
    :rackspace_api_key  => '3d5b0fd9d8f31797029d808ff5183433'
  }
  config.storage = :fog
  config.fog_directory = Rails.env.to_s
  config.fog_host = case Rails.env.to_s
  when 'development'
    "http://c7134595.r95.cf2.rackcdn.com"
  when 'production'
    "http://c7134822.r22.cf2.rackcdn.com"
  end
end