class RemoveColorColumnsFromSchools < ActiveRecord::Migration[8.0]
  def change
    remove_column :schools, :primary_color, :string
    remove_column :schools, :secondary_color, :string
    remove_column :schools, :accent_color, :string
  end
end
