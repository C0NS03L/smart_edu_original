class NamesEmailsPasswords < ActiveRecord::Migration[8.0]
  def change
    add_column :system_admins, :name, :string, null: false
    add_column :principals, :name, :string, null: false
    add_column :staffs, :name, :string, null: false
  end
end
