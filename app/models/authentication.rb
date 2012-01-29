class Authentication < ActiveRecord::Base
  METHODS = {:fb => 'facebook', :mturk => 'mturk'}

  belongs_to :user

  class << self
    def authmethods_left
      METHODS.values - all.map(&:provider)
    end
  end

  def provider_name
    if provider == 'open_id'
      "OpenID"
    else
      provider.titleize
    end
  end
end
