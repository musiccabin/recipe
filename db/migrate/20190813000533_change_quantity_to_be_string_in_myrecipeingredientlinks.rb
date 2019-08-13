class ChangeQuantityToBeStringInMyrecipeingredientlinks < ActiveRecord::Migration[5.2]
  def change
    change_column :myrecipeingredientlinks, :quantity, :string
  end
end
