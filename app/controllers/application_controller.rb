class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?

  #TODO remove hardcode
#  def current_user
#    @current_user ||= User.find_by_id(session[:user_id]) # to prevent not found exception
#    User.first
#  end

#  def current_user=(user)
#    @current_user = user
#    session[:user_id] = user.id
#  end

#  def logged_in?
#    !!current_user
#  end

#  def login_required
#    redirect_to authentications_url unless logged_in?
#  end

  def researcher_required
    redirect_to authentications_url, :error => "You must be a researcher!" if !user_signed_in? and !current_user.researcher?
  end
end
