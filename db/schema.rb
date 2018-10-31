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

ActiveRecord::Schema.define(version: 20181031220926) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "name"
    t.string   "phone_number"
    t.string   "website"
    t.string   "industry"
    t.text     "description"
    t.text     "internal_notes"
    t.boolean  "do_not_contact",       default: false
    t.string   "number_of_employees"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zipcode"
    t.string   "timezone"
    t.string   "last_funding_type"
    t.string   "last_funding_amount"
    t.string   "total_funding_raised"
    t.string   "last_funding_date"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "status"
    t.integer  "client_company_id"
    t.index ["client_company_id"], name: "index_accounts_on_client_company_id", using: :btree
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.string   "author_type"
    t.integer  "author_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree
  end

  create_table "admin_users", force: :cascade do |t|
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "campaign_replies", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "full_name"
    t.string   "last_conversation_subject"
    t.string   "last_conversation_summary"
    t.integer  "status"
    t.string   "company"
    t.string   "email"
    t.text     "notes"
    t.string   "reply_io_id"
    t.string   "reply_io_key"
    t.date     "follow_up_date"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "client_company_id"
    t.integer  "lead_id"
    t.string   "note"
    t.string   "referral_name"
    t.string   "referral_email"
    t.boolean  "pushed_to_reply_campaign",  default: false, null: false
    t.index ["client_company_id"], name: "index_campaign_replies_on_client_company_id", using: :btree
    t.index ["lead_id"], name: "index_campaign_replies_on_lead_id", using: :btree
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "industry"
    t.datetime "campaign_start"
    t.datetime "campaign_end"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "client_company_id"
    t.string   "user_notes"
    t.string   "reply_id"
    t.string   "reply_key"
    t.boolean  "personalized",            default: false
    t.integer  "persona_id"
    t.string   "campaign_name"
    t.string   "last_poll_from_reply"
    t.string   "emailAccount"
    t.integer  "deliveriesCount"
    t.integer  "opensCount"
    t.integer  "repliesCount"
    t.integer  "bouncesCount"
    t.integer  "optOutsCount"
    t.integer  "outOfOfficeCount"
    t.integer  "peopleCount"
    t.integer  "peopleFinished"
    t.integer  "peopleActive"
    t.integer  "peoplePaused"
    t.integer  "minimum_email_score"
    t.boolean  "has_minimum_email_score"
    t.integer  "campaign_type"
    t.boolean  "archive",                 default: false
    t.integer  "uniqueOpens",             default: 0
    t.integer  "contactLimit"
    t.integer  "uniquePeopleContacted"
    t.index ["client_company_id"], name: "index_campaigns_on_client_company_id", using: :btree
    t.index ["persona_id"], name: "index_campaigns_on_persona_id", using: :btree
  end

  create_table "client_companies", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.text     "company_notes"
    t.string   "company_domain"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.text     "replyio_keys"
    t.string   "api_key"
    t.integer  "number_of_seats"
    t.text     "emails_to_use"
    t.text     "products"
    t.text     "notable_clients"
    t.boolean  "account_live",            default: false
    t.string   "account_manager"
    t.string   "auto_reply_campaign_id"
    t.string   "auto_reply_campaign_key"
    t.string   "referral_campaign_key"
    t.string   "referral_campaign_id"
  end

  create_table "data_uploads", force: :cascade do |t|
    t.jsonb    "data"
    t.integer  "campaign_id"
    t.integer  "client_company_id"
    t.integer  "count"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.jsonb    "imported",                default: []
    t.jsonb    "duplicates",              default: []
    t.jsonb    "not_imported",            default: []
    t.boolean  "ignore_duplicates",       default: false
    t.string   "headers"
    t.integer  "actions"
    t.jsonb    "cleaned_data",            default: []
    t.string   "rules"
    t.integer  "user_id"
    t.boolean  "imported_to_campaigns",   default: false
    t.jsonb    "external_crm_duplicates", default: []
    t.index ["campaign_id"], name: "index_data_uploads_on_campaign_id", using: :btree
    t.index ["client_company_id"], name: "index_data_uploads_on_client_company_id", using: :btree
    t.index ["user_id"], name: "index_data_uploads_on_user_id", using: :btree
  end

  create_table "demos", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone_number"
    t.string   "comments"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "lead_actions", force: :cascade do |t|
    t.integer  "action"
    t.string   "email_open_number"
    t.string   "first_time"
    t.integer  "touchpoint_id"
    t.integer  "lead_id"
    t.integer  "client_company_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.datetime "email_sent_time"
    t.index ["client_company_id"], name: "index_lead_actions_on_client_company_id", using: :btree
    t.index ["lead_id"], name: "index_lead_actions_on_lead_id", using: :btree
    t.index ["touchpoint_id"], name: "index_lead_actions_on_touchpoint_id", using: :btree
  end

  create_table "leads", force: :cascade do |t|
    t.boolean  "decision_maker"
    t.text     "internal_notes"
    t.string   "email_in_contact_with"
    t.datetime "date_sourced"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "client_company_id"
    t.integer  "campaign_id"
    t.string   "contract_sent"
    t.integer  "contract_amount"
    t.string   "timeline"
    t.string   "project_scope"
    t.string   "email_handed_off_too"
    t.datetime "meeting_time"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "hunter_score"
    t.datetime "hunter_date"
    t.string   "title"
    t.string   "phone_type"
    t.string   "phone_number"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "linkedin"
    t.string   "timezone"
    t.string   "address"
    t.boolean  "meeting_taken",         default: false
    t.string   "full_name"
    t.integer  "status"
    t.string   "company_name"
    t.string   "company_website"
    t.integer  "account_id"
    t.index ["account_id"], name: "index_leads_on_account_id", using: :btree
    t.index ["campaign_id"], name: "index_leads_on_campaign_id", using: :btree
    t.index ["client_company_id"], name: "index_leads_on_client_company_id", using: :btree
  end

  create_table "personas", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "client_company_id"
    t.string   "description"
    t.string   "special_instructions"
    t.boolean  "archive",              default: false
    t.index ["client_company_id"], name: "index_personas_on_client_company_id", using: :btree
  end

  create_table "salesforces", force: :cascade do |t|
    t.string   "api_version"
    t.string   "username"
    t.string   "password"
    t.string   "security_token"
    t.string   "app_key"
    t.string   "app_secret"
    t.boolean  "salesforce_integration_on",                        default: false
    t.boolean  "salesforce_integration_authorized",                default: false
    t.boolean  "upload_contacts_to_salesforce_option",             default: false
    t.boolean  "check_dup_against_existing_contact_email_option",  default: false
    t.boolean  "check_dup_against_existing_account_domain_option", default: false
    t.integer  "client_company_id"
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.index ["client_company_id"], name: "index_salesforces_on_client_company_id", using: :btree
  end

  create_table "touchpoints", force: :cascade do |t|
    t.integer  "channel"
    t.string   "sender_email"
    t.string   "email_subject"
    t.string   "email_body"
    t.integer  "lead_id"
    t.integer  "campaign_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "client_company_id"
    t.index ["campaign_id"], name: "index_touchpoints_on_campaign_id", using: :btree
    t.index ["client_company_id"], name: "index_touchpoints_on_client_company_id", using: :btree
    t.index ["lead_id"], name: "index_touchpoints_on_lead_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role"
    t.integer  "client_company_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "api_key"
    t.index ["client_company_id"], name: "index_users_on_client_company_id", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "accounts", "client_companies"
  add_foreign_key "campaign_replies", "client_companies"
  add_foreign_key "campaign_replies", "leads"
  add_foreign_key "campaigns", "client_companies"
  add_foreign_key "campaigns", "personas"
  add_foreign_key "data_uploads", "client_companies"
  add_foreign_key "data_uploads", "users"
  add_foreign_key "lead_actions", "client_companies"
  add_foreign_key "lead_actions", "leads"
  add_foreign_key "lead_actions", "touchpoints"
  add_foreign_key "leads", "accounts"
  add_foreign_key "leads", "campaigns"
  add_foreign_key "leads", "client_companies"
  add_foreign_key "personas", "client_companies"
  add_foreign_key "salesforces", "client_companies"
  add_foreign_key "touchpoints", "campaigns"
  add_foreign_key "touchpoints", "client_companies"
  add_foreign_key "touchpoints", "leads"
  add_foreign_key "users", "client_companies"
end
