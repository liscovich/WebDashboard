class Hit < ActiveRecord::Base
  belongs_to :game
  has_many   :gameusers

  before_save :set_sandbox

  private

  def set_sandbox
    self.sandbox = RTurk.sandbox? if sandbox.nil?
  end
end
