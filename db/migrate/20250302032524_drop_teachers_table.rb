class DropTeachersTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :teachers
  end

  def down
    create_table :teachers do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.references :school, foreign_key: true

      t.index :email_address, unique: true

      t.timestamps
    end
  end
end
