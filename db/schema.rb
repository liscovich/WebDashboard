# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120126205016) do

  create_table "authentications", :force => true do |t|
    t.integer "user_id"
    t.string  "provider"
    t.string  "uid"
  end

  add_index "authentications", ["provider", "uid"], :name => "index_authentications_on_provider_and_uid"
  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "events", :force => true do |t|
    t.datetime "created_at"
    t.string   "state",       :limit => 50
    t.integer  "round_id"
    t.integer  "score"
    t.integer  "total_score"
    t.string   "event_type",  :limit => 50
    t.string   "choice",      :limit => 50
    t.integer  "game_id"
    t.integer  "user_id"
    t.boolean  "is_ai"
    t.string   "ai_id",       :limit => 50
    t.string   "extra",       :limit => 50
  end

  add_index "events", ["game_id"], :name => "index_events_game_id"
  add_index "events", ["user_id"], :name => "index_events_user_id"

  create_table "games", :force => true do |t|
    t.datetime "created_at"
    t.string   "gameid",            :limit => 50
    t.string   "state",             :limit => 50,                                 :default => "initialized"
    t.string   "title",             :limit => 50
    t.text     "description"
    t.integer  "totalplayers"
    t.integer  "humanplayers"
    t.integer  "numplayers"
    t.decimal  "contprob",                         :precision => 10, :scale => 2
    t.integer  "init_endow"
    t.integer  "cost_defect"
    t.integer  "cost_coop"
    t.decimal  "ind_payoff_shares",                :precision => 10, :scale => 2
    t.decimal  "exchange_rate",                    :precision => 10, :scale => 3
    t.decimal  "reward",                           :precision => 10, :scale => 2
    t.string   "hit_id",            :limit => 100
    t.string   "rturk_url",         :limit => 100
    t.boolean  "approved",                                                        :default => false
    t.integer  "user_id"
  end

  create_table "gameusers", :force => true do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.integer "final_score"
    t.boolean "mturk"
    t.string  "mturk_id",     :limit => 50
    t.decimal "bonus_amount",               :precision => 10, :scale => 2
    t.integer "state",                                                     :default => 1
  end

  create_table "hits", :force => true do |t|
    t.string  "url",     :limit => 100
    t.string  "hitid",   :limit => 50
    t.boolean "sandbox"
    t.integer "game_id"
  end

  create_table "logs", :force => true do |t|
    t.datetime "created_at"
    t.string   "name",       :limit => 50
    t.text     "parameters", :limit => 16777215
    t.string   "userid",     :limit => 50
    t.string   "gameid",     :limit => 50
    t.string   "user_id",    :limit => 50
    t.string   "game_id",    :limit => 50
  end

  create_table "specialties", :force => true do |t|
    t.string "name", :limit => 50
  end

  create_table "tests", :force => true do |t|
    t.string "name", :limit => 50
  end

  create_table "users", :force => true do |t|
    t.string   "email",                              :default => "",    :null => false
    t.string   "encrypted_password",  :limit => 128, :default => "",    :null => false
    t.datetime "remember_created_at"
    t.integer  "age"
    t.string   "location",            :limit => 50
    t.string   "institution",         :limit => 50
    t.string   "telephone",           :limit => 50
    t.text     "bio"
    t.boolean  "gender"
    t.boolean  "admin",                              :default => false
  end

end