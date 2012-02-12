class Experiment < ActiveRecord::Base
  belongs_to :creator, :class_name => 'Researcher', :foreign_key => :creator_id
  has_many   :games

  validates :name, :short_description, :presence => true

  mount_uploader :source_code, Experiments::SourceCodeUploader
  mount_uploader :bin_file,    Experiments::BinFileUploader

  default_values :title => 'Default title', :contprob => 0, :init_endow => 100,
    :cost_defect  => 0, :cost_coop => 10, :ind_payoff_shares => 0.6, :exchange_rate => 0.001,
    :totalplayers => 3, :humanplayers => 1

  #TODO remove stub
  def active?
    true
  end
end
