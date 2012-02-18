class ExperimentUpload < FileUpload
  mount_uploader :file, ExperimentUploader

  scope :current, order('id desc').limit(1)
end
