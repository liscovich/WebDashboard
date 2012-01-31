class Admin::BaseController < ApplicationController
  protected

  def admin_required
    redirect_to new_user_session_path, :error => "You must be an admin!" unless current_user.try(:admin?)
  end
end
