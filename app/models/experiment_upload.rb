class ExperimentUpload < FileUpload
  mount_uploader :file, ExperimentUploader

  scope :current, order('id desc').limit(1)

  has_many :feed_events, :dependent => :delete_all, :conditions => {:target_type => 'ExperimentUpload'}, :foreign_key => :target_id

  after_create :on_create

  # Override to silently ignore trying to remove missing
  # previous avatar when destroying a User.
  def remove_file!
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
    end
  end
  
  def remove_file
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
    end
  end

  # Override to silently ignore trying to remove missing
  # previous avatar when saving a new one.
  def remove_previously_stored_file
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
      @previous_model_for_file = nil
    end
  end

  private

  def on_create
    feed_events.create! :action => 'created', :author_id => Thread.current["current_user_id"], :target_parent_type => 'Experiment', :target_parent_id => uploader_id
  end
end
