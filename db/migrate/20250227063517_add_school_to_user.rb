class AddSchoolToUser < ActiveRecord::Migration[8.0]
  def up
    add_reference :users, :school, null: true, foreign_key: true

    execute("UPDATE users SET school_id = #{School.first.id}") if School.count > 0

    change_column_null :users, :school_id, false
  end

  def down
    remove_reference :users, :school
  end
end
