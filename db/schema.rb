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

ActiveRecord::Schema.define(version: 20170306015407) do

  create_table "events", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "rawdate"
    t.string   "location"
    t.text     "text",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "individuals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "given"
    t.string   "nickname"
    t.string   "prefix"
    t.string   "suffix"
    t.string   "pedigree"
    t.string   "sex"
    t.integer  "birth_id"
    t.integer  "death_id"
    t.string   "uid"
    t.string   "parents_uid"
    t.string   "tree"
    t.string   "gedfile"
    t.text     "note",        limit: 65535
    t.text     "gedraw",      limit: 65535
    t.integer  "ver",                       default: 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "linkuid"
    t.string   "label",                     default: ""
  end

  create_table "site_maps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "external"
    t.string   "internal"
    t.string   "aux"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "source_refs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "individual_uid"
    t.string   "union_uid"
    t.integer  "source_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "sources", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "title"
    t.text     "content",    limit: 65535
    t.string   "filename"
    t.string   "sid"
    t.string   "tree"
    t.string   "gedfile"
    t.text     "gedraw",     limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "unions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "uid"
    t.string   "husband_uid"
    t.string   "wife_uid"
    t.integer  "marriage_id"
    t.integer  "divorce_id"
    t.string   "divorced"
    t.string   "tree"
    t.text     "note",        limit: 65535
    t.string   "gedfile"
    t.text     "gedraw",      limit: 65535
    t.integer  "ver",                       default: 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_actions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_session_id"
    t.string   "controller"
    t.string   "action"
    t.string   "params"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "site",            default: "localhost"
    t.index ["user_session_id"], name: "index_user_actions_on_user_session_id", using: :btree
  end

  create_table "user_sessions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "client"
    t.string   "ip"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "site",       default: "localhost"
    t.index ["user_id"], name: "index_user_sessions_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "username"
    t.string   "email"
    t.string   "alternate_email", default: ""
    t.string   "password_digest"
    t.string   "token"
    t.string   "role",            default: "user"
    t.string   "active",          default: "unconfirmed"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "site",            default: "localhost"
  end

end
