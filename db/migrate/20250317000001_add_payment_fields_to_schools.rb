class AddPaymentFieldsToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :subscription_status, :string, default: 'pending'
    add_column :schools, :subscription_type, :string
    add_column :schools, :next_payment_date, :datetime
    add_column :schools, :student_limit, :integer, default: 0
  end
end
