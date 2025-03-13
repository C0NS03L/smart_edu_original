class AddAccountReferencesToSessions < ActiveRecord::Migration[8.0]
  def change
    add_reference :sessions, :principal, foreign_key: true, null: true
    add_reference :sessions, :staff, foreign_key: true, null: true
    add_reference :sessions, :student, foreign_key: true, null: true
  end
end
