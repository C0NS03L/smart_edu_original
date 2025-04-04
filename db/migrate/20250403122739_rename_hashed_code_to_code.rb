class RenameHashedCodeToCode < ActiveRecord::Migration[8.0]
  def change
    rename_column :enrollment_codes, :hashed_code, :code
  end
end
