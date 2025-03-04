class AddAttributesToEnrollmentCodes < ActiveRecord::Migration[8.0]
  def change
    add_column :enrollment_codes, :school_id, :integer
    add_column :enrollment_codes, :usage_limit, :integer
    add_column :enrollment_codes, :usage_count, :integer
  end
end
