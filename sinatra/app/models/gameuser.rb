class Gameuser
  include DataMapper::Resource
  property :id, Serial
  property :game_id, Integer
  property :user_id, Integer
  property :final_score, Integer

  property :mturk, Boolean
  property :mturk_id, String

  property :bonus_amount, Decimal, :scale=>2
  property :state, Enum[:waiting, :approved, :rejected, :bonused], :default=>:waiting

  belongs_to :game
  belongs_to :user
end