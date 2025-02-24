class AddSchoolFields < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :name, :string, null: false
    add_column :schools, :address, :string, null: false
    add_column :schools, :country, :string, null: false
  end
end
