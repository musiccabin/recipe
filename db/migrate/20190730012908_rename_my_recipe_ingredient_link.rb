class RenameMyRecipeIngredientLink < ActiveRecord::Migration[5.2]
  def change
    rename_table :my_recipe_ingredient_links, :myrecipeingredientlinks
  end
end
