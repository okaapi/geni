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

ActiveRecord::Schema.define(version: 20160226224239) do

  create_table "events", force: :cascade do |t|
    t.string   "rawdate",    limit: 255
    t.datetime "date"
    t.string   "location",   limit: 255
    t.text     "text",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "individuals", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "surname",     limit: 255
    t.string   "given",       limit: 255
    t.string   "nickname",    limit: 255
    t.string   "prefix",      limit: 255
    t.string   "suffix",      limit: 255
    t.string   "pedigree",    limit: 255
    t.string   "sex",         limit: 255
    t.integer  "birth_id",    limit: 4
    t.integer  "death_id",    limit: 4
    t.string   "uid",         limit: 255
    t.string   "parents_uid", limit: 255
    t.string   "tree",        limit: 255
    t.string   "gedfile",     limit: 255
    t.text     "note",        limit: 65535
    t.text     "gedraw",      limit: 65535
    t.integer  "ver",         limit: 4,     default: 0
    t.integer  "user_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_maps", force: :cascade do |t|
    t.string   "external",   limit: 255
    t.string   "internal",   limit: 255
    t.string   "aux",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "unions", force: :cascade do |t|
    t.string   "uid",         limit: 255
    t.string   "husband_uid", limit: 255
    t.string   "wife_uid",    limit: 255
    t.integer  "marriage_id", limit: 4
    t.integer  "divorce_id",  limit: 4
    t.string   "divorced",    limit: 255
    t.string   "tree",        limit: 255
    t.text     "note",        limit: 65535
    t.string   "gedfile",     limit: 255
    t.text     "gedraw",      limit: 65535
    t.integer  "ver",         limit: 4,     default: 0
    t.integer  "user_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_actions", force: :cascade do |t|
    t.integer  "user_session_id", limit: 4
    t.string   "controller",      limit: 255
    t.string   "action",          limit: 255
    t.string   "params",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "site",            limit: 255, default: "localhost"
  end

  add_index "user_actions", ["user_session_id"], name: "index_user_actions_on_user_session_id", using: :btree

  create_table "user_sessions", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "client",     limit: 255
    t.string   "ip",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "site",       limit: 255, default: "localhost"
  end

  add_index "user_sessions", ["user_id"], name: "index_user_sessions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",        limit: 255
    t.string   "email",           limit: 255
    t.string   "alternate_email", limit: 255, default: ""
    t.string   "password_digest", limit: 255
    t.string   "token",           limit: 255
    t.string   "role",            limit: 255, default: "user"
    t.string   "active",          limit: 255, default: "unconfirmed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "site",            limit: 255, default: "localhost"
  end

end
