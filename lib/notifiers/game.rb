class Notifiers::Game < Notifiers::Base
  private

  def on_created!
    each_user do |user|
      next if user.id == object.target.creator_id

      notify_user!(user)
    end
  end

  def on_updated!
    each_user do |user|
      next if user.id == object.author_id # skip event creator

      notify_user!(user)
    end
  end

  def each_user(&block)
    object.target.users.each{|user| yield user }
  end

  def notify_user!(user)
    #TODO notify_user!
    if user.notify_email?
      
    elsif user.notify_fb?

    end
  end
end
