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
