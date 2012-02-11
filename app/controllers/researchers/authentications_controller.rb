class Researchers::AuthenticationsController < ApplicationController
  def thought_provider
    session[:auth_type] = 'researcher'

    redirect_to "/auth/#{params[:provider]}"
  end
end
