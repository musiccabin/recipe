class AddIsHiddenToMyRecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :my_recipes, :is_hidden, :boolean, default: false
  end
end
