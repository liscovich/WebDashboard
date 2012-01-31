module GamesHelper
  def mturk_submit_url(current_game)
    raise "current game isn't assigned" unless current_game
    
    "#{MTURK_SUBMIT_URL}?assignmentId=#{current_game[:assignment_id]}&workerId=#{current_game[:worker_id]}&hitId=#{current_game[:hit_id]}&redirect_url=#{thanks_games_url}"
  end
end