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

ActiveRecord::Schema[8.0].define(version: 2025_04_03_122739) do
  create_table 'attendances', force: :cascade do |t|
    t.integer 'student_id', null: false
    t.datetime 'timestamp'
    t.integer 'user_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'school_id', null: false
    t.index ['school_id'], name: 'index_attendances_on_school_id'
    t.index ['student_id'], name: 'index_attendances_on_student_id'
    t.index ['user_id'], name: 'index_attendances_on_user_id'
  end

  create_table 'enrollment_codes', force: :cascade do |t|
    t.string 'code'
    t.string 'role'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'school_id'
    t.integer 'usage_limit'
    t.integer 'usage_count'
    t.string 'account_type'
  end

  create_table 'payment_histories', force: :cascade do |t|
    t.integer 'school_id', null: false
    t.decimal 'amount', precision: 10, scale: 2, null: false
    t.datetime 'payment_date', null: false
    t.string 'payment_method', null: false
    t.string 'transaction_id'
    t.string 'status', null: false
    t.string 'card_last_digits'
    t.string 'card_type'
    t.string 'subscription_plan'
    t.text 'notes'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['school_id'], name: 'index_payment_histories_on_school_id'
    t.index ['transaction_id'], name: 'index_payment_histories_on_transaction_id', unique: true
  end

  create_table 'schools', force: :cascade do |t|
    t.string 'name', null: false
    t.string 'address'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'country', null: false
    t.string 'subscription_status', default: 'pending'
    t.string 'subscription_type'
    t.datetime 'next_payment_date'
    t.integer 'student_limit', default: 0
    t.string 'timezone', default: 'Asia/Bangkok'
    t.string 'theme'
    t.string 'theme_mode'
    t.text 'custom_theme'
  end

  create_table 'sessions', force: :cascade do |t|
    t.integer 'user_id'
    t.string 'ip_address'
    t.string 'user_agent'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_id'], name: 'index_sessions_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email_address', null: false
    t.string 'password_digest', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'school_id'
    t.string 'type'
    t.string 'name'
    t.string 'uid'
    t.datetime 'discarded_at'
    t.string 'phone_number'
    t.index ['discarded_at'], name: 'index_users_on_discarded_at'
    t.index ['email_address'], name: 'index_users_on_email_address', unique: true
    t.index ['school_id'], name: 'index_users_on_school_id'
    t.index ['type'], name: 'index_users_on_type'
  end

  add_foreign_key 'attendances', 'schools'
  add_foreign_key 'attendances', 'users'
  add_foreign_key 'payment_histories', 'schools'
  add_foreign_key 'sessions', 'users'
  add_foreign_key 'users', 'schools'
end
