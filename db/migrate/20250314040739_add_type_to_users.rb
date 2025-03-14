class AddTypeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :type, :string
    add_index :users, :type

    add_column :users, :name, :string

    # From students table
    add_column :users, :uid, :string
    add_column :users, :discarded_at, :datetime
    add_index :users, :discarded_at

    # From principals table
    add_column :users, :phone_number, :string

    # Make school_id optional since SystemAdmins might not have a school
    change_column_null :users, :school_id, true
  end
end
