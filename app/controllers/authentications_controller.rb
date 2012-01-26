class AuthenticationsController < ApplicationController
  def create
    case params[:provider_id]
    when 'facebook'
      provider = request.env['omniauth.auth']['provider']
      uid = request.env['omniauth.auth']['uid']
    else
      raise "undefined provider: #{params[:provider_id]}"
    end

    if logged_in?
      Authmethod.create!(:auth_type=>provider, :auth_id=>uid, :user_id=>session[:id])
      user_id = session[:id]
    else
      u = Authmethod.find_user_by_provider(provider,uid)
      u = User.create_user_with_provider(provider, uid) if u.nil?
      self.current_user = u
      user_id = u.id
    end
    
    redirect_to users_path(user_id)
  end
end
