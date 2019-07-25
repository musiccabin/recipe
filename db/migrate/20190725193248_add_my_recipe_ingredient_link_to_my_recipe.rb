class AddMyRecipeIngredientLinkToMyRecipe < ActiveRecord::Migration[5.2]
  def change
    add_reference :my_recipes, :my_recipe_ingredient_link, foreign_key: true, index: {unique: true}
  end
end
