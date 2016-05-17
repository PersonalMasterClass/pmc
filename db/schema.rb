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

ActiveRecord::Schema.define(version: 20160517070527) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "availabilities", force: :cascade do |t|
    t.integer  "presenter_id"
    t.integer  "start_time",   default: 0
    t.integer  "end_time",     default: 0
    t.boolean  "monday",       default: false
    t.boolean  "tuesday",      default: false
    t.boolean  "wednesday",    default: false
    t.boolean  "thursday",     default: false
    t.boolean  "friday",       default: false
    t.boolean  "saturday",     default: false
    t.boolean  "sunday",       default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "bids", force: :cascade do |t|
    t.integer  "booking_id"
    t.integer  "presenter_id"
    t.datetime "bid_date"
    t.integer  "rate"
  end

  create_table "booked_customers", force: :cascade do |t|
    t.integer  "customer_id"
    t.integer  "booking_id"
    t.integer  "number_students"
    t.boolean  "paid",            default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "bookings", force: :cascade do |t|
    t.integer  "customer_id"
    t.integer  "presenter_id"
    t.datetime "booking_date"
    t.integer  "duration_minutes"
    t.string   "cancellation_message"
    t.boolean  "shared",               default: false
    t.integer  "approval"
    t.integer  "subject_id"
    t.boolean  "presenter_paid",       default: false
    t.integer  "chosen_presenter_id"
    t.integer  "creator_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "rate"
  end

  add_index "bookings", ["chosen_presenter_id"], name: "index_bookings_on_chosen_presenter_id", using: :btree
  add_index "bookings", ["creator_id"], name: "index_bookings_on_creator_id", using: :btree

  create_table "customers", force: :cascade do |t|
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

  create_table "notifications", force: :cascade do |t|
    t.boolean  "is_read",    default: false
    t.string   "reference"
    t.string   "message"
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "presenter_profiles", force: :cascade do |t|
    t.text     "bio"
    t.text     "bio_edit"
    t.integer  "status"
    t.string   "picture_uid"
    t.string   "picture_edit_uid"
    t.integer  "presenter_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "presenter_profiles", ["presenter_id"], name: "index_presenter_profiles_on_presenter_id", using: :btree

  create_table "presenters", force: :cascade do |t|
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
    t.integer  "rate"
  end

  add_index "presenters", ["user_id"], name: "index_presenters_on_user_id", using: :btree

  create_table "presenters_subjects", id: false, force: :cascade do |t|
    t.integer "presenter_id"
    t.integer "subject_id"
  end

  add_index "presenters_subjects", ["presenter_id"], name: "index_presenters_subjects_on_presenter_id", using: :btree
  add_index "presenters_subjects", ["subject_id"], name: "index_presenters_subjects_on_subject_id", using: :btree

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

  create_table "subjects", force: :cascade do |t|
    t.string   "name"
    t.string   "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
