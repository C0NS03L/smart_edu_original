class AddEmailAndPasswordToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :email_address, :string
    add_column :students, :password_digest, :string
    add_index :students, :email_address, unique: true
  end
end
