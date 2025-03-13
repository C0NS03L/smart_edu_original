class AddAccountTypeToEnrollmentCodes < ActiveRecord::Migration[8.0]
  def change
    add_column :enrollment_codes, :account_type, :string
  end
end
