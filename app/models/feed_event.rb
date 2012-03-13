class FeedEvent < ActiveRecord::Base
  ACTIONS = %w(created updated)

  belongs_to :target,        :polymorphic => true
  belongs_to :target_parent, :polymorphic => true
  belongs_to :author, :class_name => 'User'

  validates :author_id, :presence => true
  validates :action,   :inclusion => ACTIONS

  after_create :on_create

  class << self
    def feed_for_user(user)
      experiment_ids = user.user_experiments.select('experiment_id').collect(&:experiment_id)
      where(["((target_id in (?) AND target_type=?) OR (target_parent_id in (?) AND target_parent_type=?)) OR author_id=?",
        experiment_ids, 'Experiment', experiment_ids, 'Experiment', user.id]).includes(:author, :target_parent).
      order("created_at desc")
#        experiment_ids, 'Experiment', experiment_ids, 'Experiment', user.id]).includes(:author, :target, :target_parent)
    end
  end

  private

  def on_create
    case target_type
    when 'Experiment'
      Notifiers::Experiment.new(self).notify!
    when 'Game'
      Notifiers::Game.new(self).notify!
    end
  end
end
