class AddPrincipalIdToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :principal_id, :integer
    add_foreign_key :schools, :users, column: :principal_id
    add_index :schools, :principal_id
  end
end
