class Experiment < ActiveRecord::Base
  attr_accessible :name, :short_description, :title, :description, :init_endow, :cost_defect, :cost_coop, :totalplayers, :humanplayers,
    :contprob, :ind_payoff_shares, :exchange_rate, :source_code, :bin_file, :source_codes_attributes, :bin_files_attributes

  belongs_to :creator, :class_name => 'Researcher', :foreign_key => :creator_id
  has_many   :games, :dependent => :destroy
  
  with_options :class_name => '::ExperimentUpload', :foreign_key => :uploader_id, :dependent => :destroy do |a|
    has_many   :source_codes, :conditions => {:data_type => 'source_code'}
    has_many   :bin_files,    :conditions => {:data_type => 'bin_file'}
  end

  accepts_nested_attributes_for :source_codes, :bin_files, :allow_destroy => true

  validates :name, :short_description, :presence => true

  default_values :title => 'Default title', :contprob => 0, :init_endow => 100,
    :cost_defect  => 0, :cost_coop => 10, :ind_payoff_shares => 0.6, :exchange_rate => 0.001,
    :totalplayers => 3, :humanplayers => 1

  before_save :validate_attachments

  #TODO remove stub
  def active?
    true
  end

  private

  def validate_attachments
    errors.add :source_codes, "can't be blank" unless source_codes.any?
    errors.add :bin_files,    "can't be blank" unless bin_files.any?
  end
end
