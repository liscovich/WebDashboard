class ExperimentsController < ApplicationController
  inherit_resources

  before_filter :researcher_required

  respond_to :html

  def index
    @experiments = Experiment.all
  end

  def create
    create!{ experiments_path }
  end

  def update
    update!{ experiments_path }
  end

  protected

  def begin_of_association_chain
    current_user
  end
end
