# encoding: utf-8

class ExperimentUploader < BaseUploader
  def store_dir
    "uploads/experiments/#{model.data_type}/#{model.id}"
  end

#  def filename
#    "#{model.created_at.strftime("%Y-%m-%d")}.#{file.extension}" if original_filename
#  end
end
