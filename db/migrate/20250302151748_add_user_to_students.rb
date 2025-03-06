class AddUserToStudents < ActiveRecord::Migration[8.0]
  def up
    # First add the column allowing NULL values
    add_reference :students, :user, foreign_key: true, null: true

    # Create users for each student that doesn't have one
    Student
      .where(user_id: nil)
      .find_each do |student|
        # Use existing student email or generate one based on ID
        email =
          (
            if student.respond_to?(:email) && student.email.present?
              student.email
            else
              "student_#{student.id}@placeholder.com"
            end
          )

        # Create a new user
        user =
          User.create!(
            email_address: email,
            password: '12345678',
            password_confirmation: '12345678',
            created_at: '2025-03-04 17:57:00',
            updated_at: '2025-03-04 17:57:00',
            school_id: student.school_id
          )

        # Update the student with the new user
        student.update_column(:user_id, user.id)
      end

    # Then change the column to NOT NULL after populating it
    change_column_null :students, :user_id, false
  end

  def down
    remove_reference :students, :user
  end
end
