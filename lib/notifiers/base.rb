class Notifiers::Base
  attr_accessor :object

  def initialize(object)
    self.object = object
  end

  def notify!
    send "on_#{object.action}!"
  end
end
