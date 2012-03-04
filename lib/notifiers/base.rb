class Notifiers::Base
  attr_accessor :object

  def initialize(object)
    self.object = object
  end

  def notify!(stream)
    raise "unimplemented"
  end
end
