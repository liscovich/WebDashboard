class RecreateUsers < ActiveRecord::Migration
  def up
    drop_table :users

    create_table :users do |t|
#      t.string   "username",    :limit => 50
      t.database_authenticatable
      t.rememberable
      t.integer  :age
      t.string   :location, :institution, :telephone,  :limit => 50
      t.text     :bio
      t.boolean  :gender
      t.boolean  :admin, :default => false
    end
  end

  def down
    drop_table :users

    create_table "users" do |t|
      t.datetime "created_at"
      t.boolean  "complete"
      t.string   "username",    :limit => 50
      t.string   "email",       :limit => 50
      t.string   "password",    :limit => 50
      t.integer  "age"
      t.string   "location",    :limit => 50
      t.text     "bio"
      t.boolean  "gender"
      t.string   "institution", :limit => 50
      t.string   "telephone",   :limit => 50
      t.integer  "role",                      :default => 1
    end
  end
end
