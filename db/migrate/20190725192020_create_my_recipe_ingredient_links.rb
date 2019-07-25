class CreateMyRecipeIngredientLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :my_recipe_ingredient_links do |t|
      t.references :my_recipe, foreign_key: true, index: {unique: true}
      t.references :ingredient, foreign_key: true, index: {unique: true}
      t.float :quantity, index: {unique: true}
      t.string :unit, index: {unique: true}

      t.timestamps
    end
  end
end
