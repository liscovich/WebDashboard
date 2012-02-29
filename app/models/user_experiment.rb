class UserExperiment < ActiveRecord::Base
  ROLES = {:owner => 1, :contributor => 2, :viewer => 3}

  belongs_to :user
  belongs_to :experiment

  validates :role, :presence => true, :inclusion => ROLES.values
end
