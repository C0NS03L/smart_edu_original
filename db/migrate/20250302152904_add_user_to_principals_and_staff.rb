class AddUserToPrincipalsAndStaff < ActiveRecord::Migration[8.0]
  def change
    add_reference :principals, :user, null: false, foreign_key: true
    add_reference :staffs, :user, null: false, foreign_key: true
  end
end
