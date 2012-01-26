class Gameuser < ActiveRecord::Base
  belongs_to :game
  belongs_to :user

  def approve!
    update_attribute! :state, :approved
  end
end
