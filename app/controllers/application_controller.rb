class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?

  #TODO remove hardcode
  def current_user
    User.first
  end

  def current_user=(user)
    session[:user_id] = user.id
  end

  def logged_in?
    !!session[:user_id]
  end

  def login_required
    redirect_to root_url unless logged_in?
  end

  def researcher_required
    redirect_to root_url, :error => "You must be a researcher!" if !logged_in? and !current_user.researcher?
  end
end
