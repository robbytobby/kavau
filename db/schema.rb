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

ActiveRecord::Schema.define(version: 20151115171709) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "encrypted_bic"
    t.string   "encrypted_owner"
    t.string   "encrypted_iban",       null: false
    t.string   "encrypted_bank",       null: false
    t.string   "encrypted_name"
    t.string   "encrypted_bic_salt"
    t.string   "encrypted_owner_salt"
    t.string   "encrypted_iban_salt"
    t.string   "encrypted_bank_salt"
    t.string   "encrypted_name_salt"
    t.string   "encrypted_bic_iv"
    t.string   "encrypted_owner_iv"
    t.string   "encrypted_iban_iv"
    t.string   "encrypted_bank_iv"
    t.string   "encrypted_name_iv"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "address_id",           null: false
    t.string   "address_type",         null: false
  end

  create_table "addresses", force: :cascade do |t|
    t.string   "name",             null: false
    t.string   "first_name"
    t.string   "street_number"
    t.string   "city"
    t.string   "country_code"
    t.string   "salutation"
    t.string   "type",             null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "zip"
    t.string   "title"
    t.string   "email"
    t.text     "phone"
    t.text     "notes"
    t.integer  "institution_id"
    t.string   "institution_type"
  end

  create_table "balances", force: :cascade do |t|
    t.decimal  "end_amount",          precision: 9, scale: 2,                 null: false
    t.integer  "credit_agreement_id",                                         null: false
    t.date     "date",                                                        null: false
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.boolean  "manually_edited",                             default: false
    t.decimal  "interests_sum",       precision: 9, scale: 2
  end

  create_table "credit_agreements", force: :cascade do |t|
    t.decimal  "amount",              precision: 9, scale: 2, null: false
    t.decimal  "interest_rate",       precision: 4, scale: 2, null: false
    t.integer  "cancellation_period",                         null: false
    t.integer  "creditor_id",                                 null: false
    t.integer  "account_id",                                  null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "payments", force: :cascade do |t|
    t.decimal  "amount",              precision: 9, scale: 2, null: false
    t.string   "type",                                        null: false
    t.date     "date",                                        null: false
    t.integer  "credit_agreement_id",                         null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",     null: false
    t.string   "encrypted_password",     default: "",     null: false
    t.string   "login",                  default: "",     null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",          default: 0,      null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,      null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "first_name",                              null: false
    t.string   "name",                                    null: false
    t.text     "phone"
    t.string   "role",                   default: "user", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["login"], name: "index_users_on_login", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
