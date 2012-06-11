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

ActiveRecord::Schema.define(:version => 20120514062159) do

  create_table "diagnoses", :force => true do |t|
    t.integer  "medical_case_id"
    t.string   "icd10Code"
    t.string   "icd10Text"
    t.string   "icd10Version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "diagnoses", ["medical_case_id"], :name => "index_diagnoses_on_medical_case_id"

  create_table "groups", :force => true do |t|
    t.string   "distinguishedName"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "medical_cases", :force => true do |t|
    t.string   "extId"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "patient_id"
    t.string   "funcOu"
    t.string   "nurseOu"
    t.string   "extDocId"
    t.datetime "admitDateTime"
    t.datetime "dischargeDateTime"
  end

  create_table "messages", :force => true do |t|
    t.string   "dataSource"
    t.string   "messageControlId"
    t.string   "segment"
    t.integer  "composite"
    t.integer  "subcomposite"
    t.integer  "subsubcomposite"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value"
  end

  create_table "patients", :force => true do |t|
    t.string   "extId"
    t.string   "prename"
    t.string   "surname"
    t.date     "dob"
    t.string   "sex"
    t.string   "extDocId"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.string   "dataSource"
    t.string   "segment"
    t.integer  "composite"
    t.integer  "subcomposite"
    t.integer  "subsubcomposite"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value"
  end

  add_index "permissions", ["group_id"], :name => "index_permissions_on_group_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cn"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
