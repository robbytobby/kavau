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

ActiveRecord::Schema.define(version: 20160328124244) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "accounts", force: :cascade do |t|
    t.string   "encrypted_bic"
    t.string   "encrypted_owner"
    t.string   "encrypted_iban",                       null: false
    t.string   "encrypted_bank",                       null: false
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
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "address_id",                           null: false
    t.string   "address_type",                         null: false
    t.boolean  "default",              default: false
  end

  create_table "addresses", force: :cascade do |t|
    t.string   "name",              null: false
    t.string   "first_name"
    t.string   "street_number"
    t.string   "city"
    t.string   "country_code"
    t.string   "salutation"
    t.string   "type",              null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "zip"
    t.string   "title"
    t.string   "email"
    t.text     "phone"
    t.text     "notes"
    t.integer  "institution_id"
    t.string   "institution_type"
    t.string   "legal_form"
    t.hstore   "legal_information"
  end

  create_table "balances", force: :cascade do |t|
    t.decimal  "end_amount",          precision: 9, scale: 2,                         null: false
    t.integer  "credit_agreement_id",                                                 null: false
    t.date     "date",                                                                null: false
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.decimal  "interests_sum",       precision: 9, scale: 2
    t.string   "type",                                        default: "AutoBalance", null: false
  end

  create_table "credit_agreement_versions", force: :cascade do |t|
    t.string   "item_type",                             null: false
    t.integer  "item_id",                               null: false
    t.string   "event",                                 null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.date     "valid_from",                            null: false
    t.boolean  "interest_rate_changed", default: false, null: false
    t.date     "valid_until"
    t.text     "object_changes"
  end

  add_index "credit_agreement_versions", ["item_type", "item_id"], name: "index_credit_agreement_versions_on_item_type_and_item_id", using: :btree

  create_table "credit_agreements", force: :cascade do |t|
    t.decimal  "amount",              precision: 9, scale: 2, null: false
    t.decimal  "interest_rate",       precision: 4, scale: 2, null: false
    t.integer  "cancellation_period",                         null: false
    t.integer  "creditor_id",                                 null: false
    t.integer  "account_id",                                  null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.date     "terminated_at"
    t.string   "number"
    t.date     "valid_from"
  end

  create_table "funds", force: :cascade do |t|
    t.decimal  "interest_rate", precision: 4, scale: 2, null: false
    t.string   "limit"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.date     "issued_at",                             null: false
  end

  create_table "letters", force: :cascade do |t|
    t.string   "type",            null: false
    t.text     "subject"
    t.text     "content",         null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "year"
    t.datetime "pdfs_created_at"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal  "amount",              precision: 9, scale: 2, null: false
    t.string   "type",                                        null: false
    t.date     "date",                                        null: false
    t.integer  "credit_agreement_id",                         null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "sign",                                        null: false
  end

  create_table "pdfs", force: :cascade do |t|
    t.integer  "creditor_id",         null: false
    t.integer  "letter_id",           null: false
    t.string   "path",                null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "credit_agreement_id"
    t.integer  "payment_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "category",                                null: false
    t.string   "group"
    t.string   "sub_group"
    t.string   "name",                                    null: false
    t.text     "value"
    t.boolean  "obligatory",              default: false
    t.string   "type"
    t.string   "unit"
    t.string   "default"
    t.float    "number"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.string   "accepted_types"
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

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
