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

ActiveRecord::Schema.define(:version => 20120824112633) do

  create_table "criteria", :force => true do |t|
    t.integer  "request_id"
    t.integer  "datum_id"
    t.string   "criterion_type"
    t.string   "operator"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "criteria", ["datum_id"], :name => "index_criteria_on_datum_id"
  add_index "criteria", ["request_id"], :name => "index_criteria_on_request_id"

  create_table "requests", :force => true do |t|
    t.string   "prenameContact"
    t.string   "surnameContact"
    t.string   "mailContact"
    t.string   "phoneContact"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved"
    t.integer  "submit"
    t.integer  "result"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cn"
  end

  add_index "users", ["cn"], :name => "index_users_on_cn", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
