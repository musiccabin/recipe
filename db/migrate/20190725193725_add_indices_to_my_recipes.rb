class AddIndicesToMyRecipes < ActiveRecord::Migration[5.2]
  def change
    add_index :my_recipes, :title
  end
end
