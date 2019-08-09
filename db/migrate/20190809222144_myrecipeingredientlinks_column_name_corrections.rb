class MyrecipeingredientlinksColumnNameCorrections < ActiveRecord::Migration[5.2]
  def change
    rename_column :myrecipeingredientlinks, :my_recipe_id, :myrecipe_id
  end
end
