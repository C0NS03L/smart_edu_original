class AddSchoolIdToAttendances < ActiveRecord::Migration[8.0]
  def change
    add_reference :attendances, :school, null: true, foreign_key: true

    execute 'UPDATE attendances SET school_id = 1'

    change_column_null :attendances, :school_id, false
  end
end
