class AddSchoolIdToAttendances < ActiveRecord::Migration[8.0]
  def change
    add_reference :attendances, :school, null: false, foreign_key: true

    execute 'UPDATE attendances SET school_id = 1'
  end
end
