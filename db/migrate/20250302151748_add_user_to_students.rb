class AddUserToStudents < ActiveRecord::Migration[8.0]
  def up
    # Check if students table still exists
    return unless table_exists?(:students)

    # First add the column allowing NULL values
    add_reference :students, :user, foreign_key: true, null: true unless column_exists?(:students, :user_id)

    # Skip the update step since we're migrating to STI
    # This will prevent errors about missing columns in the users table

    # We can make the column nullable since we're going to drop this table anyway
    # change_column_null :students, :user_id, false
  end

  def down
    return unless table_exists?(:students)

    remove_reference :students, :user if column_exists?(:students, :user_id)
  end

  private

  def table_exists?(table_name)
    ActiveRecord::Base.connection.table_exists?(table_name)
  end

  def column_exists?(table_name, column_name)
    ActiveRecord::Base.connection.column_exists?(table_name, column_name)
  end
end
