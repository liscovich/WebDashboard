class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :store_location

  helper_method :current_user, :logged_in?

  protected

  def researcher_required
    redirect_to new_user_session_path, :error => "You must be a researcher!" unless current_user.try(:researcher?)
  end

  def store_location
    # If devise model is not User, then replace :user_return_to with :{your devise model}_return_to
    session[:user_return_to] = request.url unless ["devise/sessions", 'registrations', 'authentications'].include?(params[:controller])
  end

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  def helpers
    view_context
  end
end
