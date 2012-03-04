class CreateFeedEvents < ActiveRecord::Migration
  def change
    create_table :feed_events do |t|
      t.integer  :target_id
      t.string   :target_type
      t.integer  :target_parent_id
      t.string   :target_parent_type
      t.string   :action
      t.string   :message
      t.integer  :author_id
      t.datetime :created_at
    end

    add_index :feed_events, [:target_type, :target_id], :name => 'target_type_id'
    add_index :feed_events, [:target_parent_type, :target_parent_id], :name => 'target_parent_type_id'
    add_index :feed_events, :author_id
  end
end
