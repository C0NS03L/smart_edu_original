# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_02_23_235716) do
  create_table "attendances", force: :cascade do |t|
    t.integer "student_id", null: false
    t.datetime "timestamp"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_attendances_on_student_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "principals", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.index ["email_address"], name: "index_principals_on_email_address", unique: true
    t.index ["school_id"], name: "index_principals_on_school_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name", null: false
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "staffs", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.index ["email_address"], name: "index_staffs_on_email_address", unique: true
    t.index ["school_id"], name: "index_staffs_on_school_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.integer "school_id", null: false
    t.string "email_address"
    t.string "password_digest"
    t.index ["discarded_at"], name: "index_students_on_discarded_at"
    t.index ["email_address"], name: "index_students_on_email_address", unique: true
    t.index ["school_id"], name: "index_students_on_school_id"
  end

  create_table "system_admins", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.index ["email_address"], name: "index_system_admins_on_email_address", unique: true
  end

  create_table "teachers", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.index ["email_address"], name: "index_teachers_on_email_address", unique: true
    t.index ["school_id"], name: "index_teachers_on_school_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "attendances", "students"
  add_foreign_key "attendances", "users"
  add_foreign_key "principals", "schools"
  add_foreign_key "sessions", "users"
  add_foreign_key "staffs", "schools"
  add_foreign_key "students", "schools"
  add_foreign_key "teachers", "schools"
end
