get "/log" do
  content_type :json
  return unless request.xhr?

  cond = {}

  if params[:id]
    cond[:id.gt] = params[:id].to_i
  end

  if params[:game_id]
    cond[:game_id] = params[:game_id].to_i
  end

  logs = Log.all(:conditions=>cond, :order=>[:id])
  data = logs.map{ |l|
    {
      :id       => l.id,
      :name     => l.name,
      :params   => l.parameters,
      :game_id  => l.game_id,
      :user_id  => l.user_id
    }
  }
  data.to_json
end

get "/log/delete_all" do
  Log.all.destroy!
  flash_back "All logs deleted!"
end