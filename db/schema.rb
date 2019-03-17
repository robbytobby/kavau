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

ActiveRecord::Schema.define(version: 2019_03_17_101055) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "encrypted_bic"
    t.string "encrypted_owner"
    t.string "encrypted_iban", null: false
    t.string "encrypted_bank", null: false
    t.string "encrypted_name"
    t.string "encrypted_bic_iv"
    t.string "encrypted_owner_iv"
    t.string "encrypted_iban_iv"
    t.string "encrypted_bank_iv"
    t.string "encrypted_name_iv"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address_id", null: false
    t.string "address_type", null: false
    t.boolean "default", default: false
    t.index ["encrypted_bank_iv"], name: "index_accounts_on_encrypted_bank_iv", unique: true
    t.index ["encrypted_bic_iv"], name: "index_accounts_on_encrypted_bic_iv", unique: true
    t.index ["encrypted_iban_iv"], name: "index_accounts_on_encrypted_iban_iv", unique: true
    t.index ["encrypted_name_iv"], name: "index_accounts_on_encrypted_name_iv", unique: true
    t.index ["encrypted_owner_iv"], name: "index_accounts_on_encrypted_owner_iv", unique: true
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "first_name"
    t.string "street_number"
    t.string "city"
    t.string "country_code"
    t.string "salutation"
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "zip"
    t.string "title"
    t.string "email"
    t.text "phone"
    t.text "notes"
    t.integer "institution_id"
    t.string "institution_type"
    t.string "legal_form"
    t.hstore "legal_information"
  end

  create_table "balances", id: :serial, force: :cascade do |t|
    t.decimal "end_amount", precision: 9, scale: 2, null: false
    t.integer "credit_agreement_id", null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "interests_sum", precision: 9, scale: 2
    t.string "type", default: "AutoBalance", null: false
  end

  create_table "credit_agreement_versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_credit_agreement_versions_on_item_type_and_item_id"
  end

  create_table "credit_agreements", id: :serial, force: :cascade do |t|
    t.decimal "amount", precision: 9, scale: 2, null: false
    t.decimal "interest_rate", precision: 4, scale: 2, null: false
    t.integer "cancellation_period", null: false
    t.integer "creditor_id", null: false
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "terminated_at"
    t.string "number"
    t.date "valid_from", null: false
  end

  create_table "funds", id: :serial, force: :cascade do |t|
    t.decimal "interest_rate", precision: 4, scale: 2, null: false
    t.string "limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "issued_at", null: false
    t.integer "project_address_id", null: false
  end

  create_table "letters", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.text "subject"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.datetime "pdfs_created_at"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.decimal "amount", precision: 9, scale: 2, null: false
    t.string "type", null: false
    t.date "date", null: false
    t.integer "credit_agreement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sign", null: false
  end

  create_table "pdfs", id: :serial, force: :cascade do |t|
    t.integer "creditor_id", null: false
    t.integer "letter_id", null: false
    t.string "path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "credit_agreement_id"
    t.integer "payment_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "category", null: false
    t.string "group"
    t.string "sub_group"
    t.string "name", null: false
    t.text "value"
    t.boolean "obligatory", default: false
    t.string "type"
    t.string "unit"
    t.string "default"
    t.float "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.integer "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.string "accepted_types"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "login", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", null: false
    t.string "name", null: false
    t.text "phone"
    t.string "role", default: "user", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["login"], name: "index_users_on_login", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
