class AuthenticationsController < ApplicationController
  def create
    # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
    omniauth = request.env["omniauth.auth"]

    if omniauth and authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, authentication.user)
    elsif params[:mturk] and authentication = Authentication.find_by_provider_and_uid(Authentication::METHODS[:mturk], params[:mturk][:mturk_id])
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      params[:mturk] ? current_user.apply_mturk(params[:mturk]) : current_user.apply_omniauth(omniauth)
      current_user.save!
      flash[:notice] = "Authentication successful."
      redirect_to authentications_url
    else
      user = User.researcher.male.new
      params[:mturk] ? user.apply_mturk(params[:mturk]) : user.apply_omniauth(omniauth)
      
      user.save!
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, user)
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end
end
