class AddPhoneNumberToPrincipals < ActiveRecord::Migration[8.0]
  def change
    add_column :principals, :phone_number, :string
  end
end
