class Notifiers::Game < Notifiers::Base
  private

  def on_created!
    each_user do |user|
      notify_user!(user)
    end

    each_reasearcher do |user|
      next if user.id == object.user_id # creator

      notify_researcher!(object.target, user)
    end
  end

  def each_user(&block)
    User.all.each{|user| yield user }
  end

  def notify_user!(user)
    if user.notify_email?
      UserMailer.send("game_created", object.target, user).deliver
    elsif user.notify_fb?
      #TODO
    end
  end

  def each_reasearcher(&block)
    object.target.users.each{|user| yield user }
  end

  def notify_researcher!(experiment, user)
    if user.notify_email?
      ResearcherMailer.send("game_created", object, experiment, user).deliver
    elsif user.notify_fb?
      #TODO
    end
  end
end
