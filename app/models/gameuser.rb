class Gameuser < ActiveRecord::Base
  STATES = {:unapproved => 1, :approved => 2}
  
  belongs_to :game
  belongs_to :user

  def approve
    update_attribute :state, STATES[:approved]
  end

  def approved?
    state == STATES[:approved]
  end
end
