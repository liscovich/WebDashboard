class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?

  protected

  def researcher_required
    redirect_to new_user_session_path, :error => "You must be a researcher!" unless current_user.try(:researcher?)
  end

  def helpers
    view_context
  end
end
