class CreateSystemAdmins < ActiveRecord::Migration[8.0]
  def change
    create_table :system_admins do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index :email_address, unique: true

      t.timestamps
    end
  end
end