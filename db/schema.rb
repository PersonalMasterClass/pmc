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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160412052905) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "availabilities", force: :cascade do |t|
    t.integer  "days"
    t.integer  "start_time"
    t.integer  "end_time"
    t.integer  "presenter_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string   "email"
    t.string   "phone_number"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "vit_number"
    t.integer  "user_id"
    t.string   "abn_number"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "department"
    t.string   "contact_title"
    t.integer  "school_info_id"
  end

  create_table "presenter_profiles", force: :cascade do |t|
    t.text     "bio"
    t.text     "bio_edit"
    t.integer  "status"
    t.string   "picture"
    t.string   "picture_edit"
    t.integer  "presenter_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "presenter_profiles", ["presenter_id"], name: "index_presenter_profiles_on_presenter_id", using: :btree

  create_table "presenters", force: :cascade do |t|
    t.string   "email"
    t.string   "phone_number"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "vit_number"
    t.string   "abn_number"
    t.integer  "school_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "user_id"
    t.integer  "school_info_id"
  end

  add_index "presenters", ["user_id"], name: "index_presenters_on_user_id", using: :btree

  create_table "school_infos", force: :cascade do |t|
    t.string   "sector"
    t.string   "school_name"
    t.string   "school_type"
    t.string   "principal"
    t.string   "address"
    t.string   "town"
    t.string   "state"
    t.string   "postcode"
    t.string   "postal_address"
    t.string   "postal_town"
    t.string   "postal_state"
    t.string   "postal_postcode"
    t.string   "phone_number"
    t.string   "fax_number"
    t.string   "region_name"
    t.string   "lga_name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "username"
    t.integer  "user_type"
    t.integer  "status"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "presenter_profiles", "presenters"
end
