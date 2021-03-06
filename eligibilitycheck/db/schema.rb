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

ActiveRecord::Schema.define(:version => 20120824134549) do

  create_table "diagnoses", :force => true do |t|
    t.integer  "medical_case_id"
    t.string   "icd10Code"
    t.string   "icd10Text"
    t.string   "icd10Version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "read_status"
    t.string   "extDocId"
  end

  add_index "diagnoses", ["medical_case_id"], :name => "index_diagnoses_on_medical_case_id"

  create_table "medical_cases", :force => true do |t|
    t.string   "extCaseId"
    t.integer  "patient_id"
    t.string   "funcOu"
    t.string   "nurseOu"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "read_status"
    t.string   "extDocId"
  end

  add_index "medical_cases", ["patient_id"], :name => "index_medical_cases_on_patient_id"

  create_table "patients", :force => true do |t|
    t.string   "extId"
    t.string   "prename"
    t.string   "surname"
    t.date     "dob"
    t.string   "sex"
    t.string   "extDocId"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "trial_id"
    t.integer  "consent_status"
    t.integer  "self_service_status"
    t.integer  "read_status"
  end

  add_index "patients", ["trial_id"], :name => "index_patients_on_trial_id"

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
    t.string   "extDocId"
  end

  add_index "users", ["cn"], :name => "index_users_on_cn", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
