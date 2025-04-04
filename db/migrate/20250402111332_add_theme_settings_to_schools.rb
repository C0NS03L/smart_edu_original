class AddThemeSettingsToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :theme, :string
    add_column :schools, :theme_mode, :string
    add_column :schools, :primary_color, :string
    add_column :schools, :secondary_color, :string
    add_column :schools, :accent_color, :string
    add_column :schools, :custom_theme, :text
  end
end
