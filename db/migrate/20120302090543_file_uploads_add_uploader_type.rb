class FileUploadsAddUploaderType < ActiveRecord::Migration
  def up
    add_column :file_uploads, :uploader_type, :string
    add_index  :file_uploads, :uploader_type

    ExperimentUpload.update_all :uploader_type => 'Experiment'
  end

  def down
    remove_column :file_uploads, :uploader_type
  end
end
