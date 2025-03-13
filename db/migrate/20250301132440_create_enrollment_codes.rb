class CreateEnrollmentCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :enrollment_codes do |t|
      t.string :hashed_code
      t.string :role

      t.timestamps
    end
  end
end
