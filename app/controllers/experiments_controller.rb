class ExperimentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :researcher_required

  def index
    render :layout => false
  end
end
