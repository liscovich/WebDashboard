class Notifiers::Experiment < Notifiers::Base
  def notify!
    send "on_#{object.action}!"
  end

  private

  def on_created!
    each_reasearcher do |user|
      next if user.id == object.target.creator_id

      notify_user!(user, :created)
    end
  end

  def on_updated!
    each_reasearcher do |user|
      next if user.id == object.author_id # skip event creator

      notify_user!(user, :updated)
    end
  end

  def each_reasearcher(&block)
    object.target.users.each{|user| yield user }
  end

  def notify_user!(user, action)
    if user.notify_by_email?
      ResearcherMailer.send("experiment_#{action}", object, user).deliver
    elsif user.notify_fb?
      #TODO
    end
  end
end
