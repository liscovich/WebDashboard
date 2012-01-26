class HitsController < ApplicationController
  before_filter :researcher_required, :except => [:index, :dispose_all]
  before_filter :find_hit,            :except => [:index, :dispose_all]

  def index
    #TODO
  end

  def show
    @game = Game.find(params[:game_id])
  end

  def dispose_all
    p1 = fork do
      hits = RTurk::Hit.all_reviewable
      hits.each do |hit|
        hit.expire!
        hit.assignments.each do |a|
          a.approve!
        end
        hit.dispose!
      end
    end
    Process.detach p1

    redirect_to hits_path, :notice => "Disposed all hits!"
  end

  def approve
    @hit.assignments.each do |a|
      a.approve! if a.status=='Submitted'
      am = Authmethod.first(:auth_type=>'mturk', :auth_id=>a.worker_id)
      h = Hit.first(:hitid=>params[:id])
      if am and h
        gu = Gameuser.first(:user_id=>am.user_id, :game_id=>h.game_id)
        gu.mturk_id = am.auth_id
        gu.mturk = true
        gu.state = :approved
        gu.save
      end
    end
    @hit.expire!
    
    redirect_to hits_path, :notice => "You approved hit id #{params[:id]}!"
  end

  def reject
    reason = params[:reason] || 'You did not finish the assignment properly!'
    @hit.assignments.each do |a|
      a.reject!(reason) if a.status=='Submitted'
      am = Authmethod.first(:auth_type=>'mturk', :auth_id=>a.worker_id)
      h = Hit.first(:hitid=>params[:id])
      if am and h
        gu = Gameuser.first(:user_id=>am.user_id, :game_id=>h.game_id)
        gu.mturk_id = am.auth_id
        gu.mturk = true
        gu.state = :rejected
        gu.save
      end
    end
    @hit.expire!
    
    redirect_to hits_path, :notice => "You rejected hit id #{params[:id]}"
  end

  def bonus
    @hit.assignments.each do |a|
      if a.status=='Submitted'
        am = Authmethod.first(:auth_type=>'mturk', :auth_id=>a.worker_id)
        h = Hit.first(:hitid=>params[:id])
        if am and h
          gu = Gameuser.first(:user_id=>am.user_id, :game_id=>h.game_id)
          gu.mturk_id = am.auth_id
          gu.mturk = true
          gu.bonus_amount = (h.game.exchange_rate*gu.final_score).round(2)
          gu.state = :bonused
          gu.save

          a.bonus!(gu.bonus_amount, "You earned $#{gu.bonus_amount} from doing well this round!")
          a.approve!
        end
      end
    end
    @hit.expire!
    redirect_to hits_path, :notice => "You bonused hit id #{params[:id]} with amount #{params[:amount]}"
  end

  def dispose
    @hit.dispose!
    h = RTurk::Hit.find(params[:id])
    h.dispose! if h

    redirect_to hits_path, :notice => "You disposed of a HIT!"
  end

  private

  def find_hit
    @hit = RTurk::Hit.find(params[:id])
    unless @hit
      flash[:error] = "Cannot find HIT!"
      deny!
    end
  end
end
