class AddTimezoneToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :timezone, :string, default: 'Asia/Bangkok'
  end
end
