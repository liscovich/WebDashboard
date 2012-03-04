class ExperimentsController < ApplicationController
  inherit_resources

  before_filter :researcher_required
  before_filter :permissions_check, :only => [:edit, :update]

  respond_to :html

  def index
    @public_experiments  = Experiment.public.all :include => :creator
    @private_experiments = Experiment.where(:id => current_user.user_experiments.select('experiment_id').collect(&:experiment_id)).all(:include => :creator)
  end

  def create
    create! { experiments_path }
  end

  def update
    update! { experiments_path }
  end

  protected

  def permissions_check
    redirect_to experiments_path unless current_user.can_edit?(Experiment.find(params[:id]))
  end

  def begin_of_association_chain
    ['new', 'create'].include?(params[:action]) ? current_user : nil
  end
end
