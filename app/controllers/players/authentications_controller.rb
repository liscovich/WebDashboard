class Players::AuthenticationsController < ApplicationController
  def thought_provider
    session[:auth_type] = 'player'

    redirect_to "/auth/#{params[:provider]}"
  end
end
