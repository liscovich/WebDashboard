class Hit < ActiveRecord::Base
  belongs_to :game
  has_many   :gameusers
end
