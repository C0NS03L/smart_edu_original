class RemoveUserIdFromOthers < ActiveRecord::Migration[8.0]
  def change
    remove_column :principals, :user_id, :integer
    remove_column :students, :user_id, :integer
    remove_column :staffs, :user_id, :integer
  end
end
