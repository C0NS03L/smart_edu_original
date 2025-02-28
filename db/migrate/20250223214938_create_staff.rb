class CreateStaff < ActiveRecord::Migration[8.0]
  def change
    create_table :staffs do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.references :school, foreign_key: true

      t.index :email_address, unique: true

      t.timestamps
    end
  end
end
