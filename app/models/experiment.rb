class Experiment < ActiveRecord::Base
  attr_accessible :name, :short_description, :title, :description, :init_endow, :cost_defect, :cost_coop, :totalplayers, :humanplayers,
    :contprob, :ind_payoff_shares, :exchange_rate, :source_code, :bin_file, :source_codes_attributes, :bin_files_attributes, :contributors_attributes,
    :public, :draft

  has_many :user_experiments, :dependent => :delete_all
  has_many :users, :through => :user_experiments
  has_many :contributors, :class_name => 'UserExperiment', :conditions => {"user_experiments.role" => UserExperiment::ROLES[:contributor]}, :dependent => :delete_all

  has_many :games,   :dependent => :destroy
  has_many :feed_events, :dependent => :delete_all, :conditions => {:target_type => 'Experiment'}, :foreign_key => :target_id

  belongs_to :creator, :class_name => 'User', :foreign_key => :creator_id
  
  with_options :class_name => '::ExperimentUpload', :foreign_key => :uploader_id, :dependent => :destroy do |a|
    a.has_many :source_codes, :conditions => {:data_type => 'source_code', :uploader_type => 'Experiment'}
    a.has_many :bin_files,    :conditions => {:data_type => 'bin_file',    :uploader_type => 'Experiment'}
  end

  accepts_nested_attributes_for :source_codes, :bin_files, :contributors, :allow_destroy => true

  validates :name, :short_description, :presence => true

  default_values :public => true,
    :title => 'Default title', :contprob => 0, :init_endow => 100,
    :cost_defect  => 0, :cost_coop => 10, :ind_payoff_shares => 0.6, :exchange_rate => 0.001,
    :totalplayers => 3, :humanplayers => 1

  scope :public,  where(:public => true)
  scope :private, where(:public => false)

  after_create do
    add_owner!(creator)
    feed_events.create! :action => 'created', :author_id => creator_id
  end
  
  before_save :validate_attachments
  after_save do
    feed_events.create! :action => 'updated', :author_id => Thread.current["current_user_id"]
  end

  UserExperiment::ROLES.keys.each do |n|
    define_method("add_#{n}!") do |user|
      user_experiments.create! :user => user, :role => UserExperiment::ROLES[n]
    end
  end

  def owner?(u)
    u.id == creator_id
  end

  def game_can_be_created?
    !draft?
  end

  private

  def validate_attachments
    errors.add :source_codes, "can't be blank" unless source_codes.any?
    errors.add :bin_files,    "can't be blank" unless bin_files.any?
  end
end
