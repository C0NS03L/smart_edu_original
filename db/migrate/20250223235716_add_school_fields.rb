class AddSchoolFields < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :country, :string, null: false
  end
end
