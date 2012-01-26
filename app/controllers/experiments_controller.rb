class ExperimentsController < ApplicationController
  before_filter :login_required
  before_filter :researcher_required

  def index
    render :layout => false
  end
end
