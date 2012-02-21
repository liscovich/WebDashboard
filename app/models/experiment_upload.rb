class ExperimentUpload < FileUpload
  mount_uploader :file, ExperimentUploader

  scope :current, order('id desc').limit(1)

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
end
