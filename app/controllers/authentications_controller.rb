class AuthenticationsController < ApplicationController
  def create
    # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
    omniauth   = request.env["omniauth.auth"]
    conditions = {'users.role' => session[:auth_type], :provider => omniauth['provider'], :uid => omniauth['uid']}
    
    if omniauth and session[:auth_type] and Authentication.joins(:user).where(conditions).exists?
      authentication = Authentication.joins(:user).where(conditions).first
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, authentication.user)
    elsif params[:mturk] and authentication = Authentication.mturk.find_by_uid(params[:mturk][:mturk_id])
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      params[:mturk] ? current_user.apply_mturk(params[:mturk]) : current_user.apply_omniauth(omniauth)
      current_user.save!
      flash[:notice] = "Authentication successful."
      redirect_to authentications_url
    else # sign up form
      user = user_model.male.new
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

  private

  def user_model
    case session[:auth_type]
    when 'player'
      Player
    when 'researcher'
      Researcher
    else
      #TODO redirect to..
      raise "undefined user type: #{session[:auth_type]}"
    end
  end
end
