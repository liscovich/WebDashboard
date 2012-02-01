source 'https://rubygems.org'

gem 'rails', '3.2.0'
#gem "mongo_mapper"
#gem 'bson_ext'
gem 'mysql2'
gem "haml"
gem "jquery-rails"

# Gems used only for assets and not required
# in production environments by default.
gem 'sass-rails', '~> 3.2.3'
group :assets do
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'
  gem 'uglifier', '>= 1.0.3'
end

gem 'yajl-ruby'
#gem 'sass'
gem "compass", ">= 0.11.7"
#gem 'compass-rails', :git => 'git://github.com/Compass/compass-rails.git'

gem 'slim' #TODO migrate to haml and remove
gem 'rturk'

##### AUTH #####
gem 'devise'

gem 'omniauth'
gem "omniauth-twitter"
gem 'omniauth-facebook'
#gem 'openid'
#gem 'omniauth-openid'

group :development do
  gem "mongrel", '>= 1.2.0.pre2'
  gem 'rspec-rails'
  gem 'capistrano'
  gem 'capistrano_colors'
  # To use debugger
#  gem 'ruby-debug19', :require => 'ruby-debug'
end

group :production do
#  gem 'unicorn'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'
