class MyrecipesColumnNameCorrections < ActiveRecord::Migration[5.2]
  def change
    rename_column :myrecipes, :my_recipe_ingredient_link_id, :myrecipeingredientlink_id
  end
end
