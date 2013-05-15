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

ActiveRecord::Schema.define(:version => 20130515053426) do

  create_table "criteria", :force => true do |t|
    t.string   "value"
    t.string   "criterion_type"
    t.string   "operator"
    t.integer  "trial_id"
    t.integer  "datum_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "criteria", ["datum_id"], :name => "index_criteria_on_datum_id"
  add_index "criteria", ["trial_id"], :name => "index_criteria_on_trial_id"

  create_table "data", :force => true do |t|
    t.string   "description"
    t.string   "segment"
    t.integer  "composite"
    t.integer  "subcomposite"
    t.integer  "subsubcomposite"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "hint"
    t.string   "regex"
    t.string   "hint_short"
    t.string   "data_source"
  end

  create_table "hits", :force => true do |t|
    t.integer  "trial_id"
    t.string   "nurse_ou"
    t.string   "func_ou"
    t.string   "ext_doc_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hits", ["trial_id"], :name => "index_hits_on_trial_id"

  create_table "physicians", :force => true do |t|
    t.integer  "trial_id"
    t.string   "extDocId"
    t.integer  "counter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "physicians", ["trial_id"], :name => "index_physicians_on_trial_id"

  create_table "trials", :force => true do |t|
    t.string   "extId"
    t.string   "description"
    t.integer  "recruitingTarget"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "prenameInvestigator"
    t.string   "surnameInvestigator"
    t.string   "mailInvestigator"
    t.string   "informed_consent_file_name"
    t.string   "informed_consent_content_type"
    t.integer  "informed_consent_file_size"
    t.datetime "informed_consent_updated_at"
    t.integer  "recruiting_status"
    t.boolean  "activated"
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
