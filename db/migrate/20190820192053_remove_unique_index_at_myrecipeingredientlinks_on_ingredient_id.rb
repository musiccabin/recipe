class RemoveUniqueIndexAtMyrecipeingredientlinksOnIngredientId < ActiveRecord::Migration[5.2]
  def change
    remove_index :myrecipeingredientlinks, :ingredient_id
    add_index :myrecipeingredientlinks, :ingredient_id
  end
end
