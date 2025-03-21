class CreatePaymentHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_histories do |t|
      t.references :school, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :payment_date, null: false
      t.string :payment_method, null: false
      t.string :transaction_id
      t.string :status, null: false
      t.string :card_last_digits
      t.string :card_type
      t.string :subscription_plan
      t.text :notes

      t.timestamps
    end

    add_index :payment_histories, :transaction_id, unique: true
  end
end
