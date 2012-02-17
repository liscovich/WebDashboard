class CreateUploads < ActiveRecord::Migration
  def change
    create_table :file_uploads do |t|
      t.belongs_to :uploader
      t.string     :data_type, :file
      t.datetime   :created_at
    end

    add_index :file_uploads, [:uploader_id, :data_type]
  end
end
