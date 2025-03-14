class MigrateToSingleTableInheritance < ActiveRecord::Migration[8.0]
  def up
    # Migrate principals to users
    execute <<-SQL
      INSERT INTO users (email_address, password_digest, name, school_id, type, created_at, updated_at)
      SELECT email_address, password_digest, name, school_id, 'Principal', created_at, updated_at
      FROM principals
    SQL

    # Migrate staffs to users
    execute <<-SQL
      INSERT INTO users (email_address, password_digest, name, school_id, type, created_at, updated_at)
      SELECT email_address, password_digest, name, school_id, 'Staff', created_at, updated_at
      FROM staffs
    SQL

    # Migrate existing users to have type 'Staff'
    execute <<-SQL
      UPDATE users 
      SET type = 'Staff' 
      WHERE type IS NULL
    SQL

    # Migrate students to users (need to handle uid separately)
    # First make sure the uid column exists in users table
    add_column :users, :uid, :string unless column_exists?(:users, :uid)

    execute <<-SQL
      INSERT INTO users (email_address, password_digest, name, school_id, type, uid, created_at, updated_at, discarded_at)
      SELECT COALESCE(email_address, concat('student_', id, '@example.com')), 
             COALESCE(password_digest, '$2a$12$jlyXBdc6Dmy2B08uubyjBObj0sYbu8IhjRFiQ5AzYtqg/3kinPUBW'), 
             name, school_id, 'Student', uid, created_at, updated_at, discarded_at
      FROM students
    SQL

    # Migrate system_admins to users
    execute <<-SQL
      INSERT INTO users (email_address, password_digest, name, school_id, type, created_at, updated_at)
      SELECT email_address, password_digest, name, NULL, 'SystemAdmin', created_at, updated_at
      FROM system_admins
    SQL

    # Update sessions to use only user_id
    execute <<-SQL
      UPDATE sessions
      SET user_id = (SELECT users.id FROM users WHERE users.email_address = (
        SELECT email_address FROM principals WHERE principals.id = sessions.principal_id
      ))
      WHERE principal_id IS NOT NULL AND user_id IS NULL
    SQL

    execute <<-SQL
      UPDATE sessions
      SET user_id = (SELECT users.id FROM users WHERE users.email_address = (
        SELECT email_address FROM staffs WHERE staffs.id = sessions.staff_id
      ))
      WHERE staff_id IS NOT NULL AND user_id IS NULL
    SQL

    execute <<-SQL
      UPDATE sessions
      SET user_id = (SELECT users.id FROM users WHERE users.email_address = (
        SELECT email_address FROM students WHERE students.id = sessions.student_id
      ))
      WHERE student_id IS NOT NULL AND user_id IS NULL
    SQL
  end

  def down
    # This is a complex migration to reverse - would need careful handling
    raise ActiveRecord::IrreversibleMigration
  end
end
