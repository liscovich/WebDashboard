class ApplicationController < ActionController::Base
  include UrlHelper
  
  protect_from_forgery

  before_filter :store_location
  before_filter :store_current_user

  helper_method :current_user

  protected

  def researcher_required
    redirect_to new_researcher_session_url(:subdomain => DOMAINS[:researcher]), :error => "You must be a researcher!" unless current_user.try(:researcher?)
  end

  def store_current_user
    Thread.current["current_user_id"] = current_user.id if signed_in?
  end

  def store_location
    # If devise model is not User, then replace :user_return_to with :{your devise model}_return_to
    session[:user_return_to] = request.url unless
      ["sessions", "devise/sessions", 'registrations', 'players/authentications', 'researchers/authentications', 'authentications'].include?(params[:controller])
  end

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  def authenticate_researcher_or_player!
    unless player_signed_in? || researcher_signed_in?
      as = request.subdomains.include?(DOMAINS[:researcher]) ? :researcher : :player
      redirect_to session_path(as)
    end
  end

  def current_user
    current_player || current_researcher
  end

  def helpers
    view_context
  end
end
