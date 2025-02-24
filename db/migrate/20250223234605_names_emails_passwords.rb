class NamesEmailsPasswords < ActiveRecord::Migration[8.0]
  def change
    add_column :system_admins, :email_address, :string, null: false
    add_column :system_admins, :password_digest, :string, null: false
    add_column :system_admins, :name, :string, null: false
    add_index :system_admins, :email_address, unique: true
    add_column :principals, :email_address, :string, null: false
    add_column :principals, :password_digest, :string, null: false
    add_column :principals, :name, :string, null: false
    add_index :principals, :email_address, unique: true
    add_column :staffs, :email_address, :string, null: false
    add_column :staffs, :password_digest, :string, null: false
    add_column :staffs, :name, :string, null: false
    add_index :staffs, :email_address, unique: true
    add_column :teachers, :email_address, :string, null: false
    add_column :teachers, :password_digest, :string, null: false
    add_column :teachers, :name, :string, null: false
    add_index :teachers, :email_address, unique: true
  end
end
