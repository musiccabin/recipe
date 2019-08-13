class AddExpiryDateToMyrecipeingredientlinks < ActiveRecord::Migration[5.2]
  def change
    add_column :myrecipeingredientlinks, :expiry_date, :date
  end
end
