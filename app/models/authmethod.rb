class Authmethod < ActiveRecord::Base
  TYPES = {:mturk => 'mturk'} #TODO add more

  belongs_to :user

  scope :mturk, where(:auth_type => 'mturk')

  class << self
    def find_user_by_provider(provider, uid)
      where(:auth_type => provider, :auth_id => uid).first.try(:user)
    end
  end

  def image_id
    {
      'mturk' => 'amazon',
      'facebook' => 'facebook'
    }[self.auth_type]
  end
end
