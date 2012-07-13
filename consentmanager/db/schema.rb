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

ActiveRecord::Schema.define(:version => 20120516133331) do

  create_table "consents", :force => true do |t|
    t.integer  "patient_id"
    t.integer  "trial_id"
    t.string   "prenamePhysician"
    t.string   "surnamePhysician"
    t.string   "mailPhysician"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
    t.integer  "subject_id"
  end

  add_index "consents", ["patient_id"], :name => "index_consents_on_patient_id"
  add_index "consents", ["trial_id"], :name => "index_consents_on_trial_id"

  create_table "subjects", :force => true do |t|
    t.string   "prename"
    t.string   "surname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
