# encoding: utf-8

class BaseUploader < CarrierWave::Uploader::Base
#  configure do |config|
#    config.remove_previously_stored_files_after_update = false
#  end

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog

  # Override to silently ignore trying to remove missing previous file
  def remove!
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
    end
  end

  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
#  def filename
#    "#{model.created_at.strftime("%Y-%m-%d")}.#{file.extension}" if original_filename
#  end
end
