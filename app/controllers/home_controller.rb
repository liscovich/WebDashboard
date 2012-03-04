class HomeController < ApplicationController
  respond_to :html

  def dashboard
    @activities = FeedEvent.feed_for_user(current_user).page(params[:page])
  end
end
