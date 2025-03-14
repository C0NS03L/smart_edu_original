class DropRedundantTables < ActiveRecord::Migration[8.0]
  def up
    # First remove all foreign keys pointing to these tables
    remove_foreign_key :attendances, :students
    remove_foreign_key :sessions, :principals
    remove_foreign_key :sessions, :staffs
    remove_foreign_key :sessions, :students

    # Then remove the columns referencing these tables
    remove_column :sessions, :principal_id
    remove_column :sessions, :staff_id
    remove_column :sessions, :student_id

    # Finally drop the tables
    drop_table :principals
    drop_table :staffs
    drop_table :students
    drop_table :system_admins
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "Cannot restore tables after they've been dropped. Restore from backup if needed."
  end
end
