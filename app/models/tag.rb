class Tag < ActiveRecord::Base
  belongs_to :feed_event

  validates :namespace, :presence => true, :unless => lambda{|tag| tag.namespace.nil? }
  validates :predicate, :presence => true, :unless => lambda{|tag| tag.predicate.nil? }

  after_initialize :downcase_fields

  def machine_tag?
    !!namespace
  end
  
  def event_author?
    has_namespace?("event") && has_predicate?("author")
  end

  def event_type?
    has_namespace?("event") && has_predicate?("type")
  end

  def to_s
    if machine_tag?
      "#{namespace}:#{predicate}=#{value}"
    else
      "#{value}"
    end
  end

  def ==(other)
    return false unless other.is_a? Tag

    self.namespace == other.namespace && self.predicate == other.predicate && self.value == other.value
  end

  def <=> other
    if self == other
      0
    elsif self.namespace != other.namespace
      self.namespace <=> other.namespace
    elsif self.predicate != other.predicate
      self.predicate <=> other.predicate
    else
      self.value <=> other.value
    end
  end

  private

  def has_namespace?(namespace)
    self.namespace == namespace
  end

  def has_predicate?(predicate)
    self.predicate == predicate
  end

  def downcase_fields
    self.namespace.downcase! unless self.namespace.nil?
    self.predicate.downcase! unless self.predicate.nil?
  end
end
