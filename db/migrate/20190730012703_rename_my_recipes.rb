class RenameMyRecipes < ActiveRecord::Migration[5.2]
  def change
    rename_table :my_recipes, :myrecipes
  end
end
