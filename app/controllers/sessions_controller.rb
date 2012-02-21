class SessionsController < Devise::RegistrationsController
  def new
    session[:auth_type] = request.path =~ /#{DOMAINS[:researcher]}/ || request.subdomains.include?(DOMAINS[:researcher]) ? 'player' : 'researcher'
    super
  end
end
