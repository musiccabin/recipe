class RemoveMyRecipeFromIngredients < ActiveRecord::Migration[5.2]
  def change
    remove_reference :ingredients, :my_recipe, foreign_key: true
  end
end
