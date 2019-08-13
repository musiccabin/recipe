class RemoveUniqueIndexAtMyrecipeingredientlinksOnQuantity < ActiveRecord::Migration[5.2]
  def change
    remove_index :myrecipeingredientlinks, :quantity
    add_index :myrecipeingredientlinks, :quantity
  end
end
