class AddSchoolToStudents < ActiveRecord::Migration[8.0]
  def up
    # First add the column without constraints
    add_reference :students, :school, null: true, foreign_key: true

    # Create a placeholder school if needed
    School.reset_column_information
    placeholder_school = School.find_or_create_by!(name: 'Placeholder School')

    # Update existing students to use the placeholder school
    execute("UPDATE students SET school_id = #{placeholder_school.id} WHERE school_id IS NULL") if Student.count > 0

    # Now add the NOT NULL constraint
    change_column_null :students, :school_id, false
  end

  def down
    remove_reference :students, :school
  end
end
