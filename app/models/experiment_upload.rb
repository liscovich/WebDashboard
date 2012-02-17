class ExperimentUpload < FileUpload
  mount_uploader :file, ExperimentUploader
end
