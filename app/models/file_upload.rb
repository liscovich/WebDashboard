class FileUpload < ActiveRecord::Base
  belongs_to :uploader, :polymorphic => true, :touch => true
end
