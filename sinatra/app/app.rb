RESET_CACHE = Time.now.to_i

post "/authmethod/mturk" do
  login_required
  Authmethod.create({
    :user_id=>session[:id],
    :auth_type=>'mturk',
    :auth_id=>params[:mturk_id] 
  })
  flash_back "You linked yourself to MTurk!"
end

get "/signup" do
  slim :"pages/signup"
end

get "/logout" do
  session.clear
  redirect_flash '/',:error, "Goodbye!"
end

post "/login" do
  u = User.auth(params[:user])
  flash_back "Your login information is incorrect!" if u.nil?
  u.sign_in!(session)
  redirect_flash '/trials', :error, "You are now logged in!"
end
