class CreateAuthentications < ActiveRecord::Migration
  def up
    create_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
    end
    add_index :authentications, :user_id
    add_index :authentications, [:provider, :uid]

    drop_table :authmethods
  end

  def down
    drop_table :authentications

    create_table "authmethods" do |t|
      t.datetime "created_at"
      t.string   "auth_type",  :limit => 50
      t.string   "auth_id",    :limit => 50
      t.integer  "user_id"
    end
    add_index "authmethods", ["auth_type", "auth_id"], :name => "unique_authmethods_u", :unique => true
  end
end
