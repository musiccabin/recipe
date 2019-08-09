class FavouritesColumnNameCorrections < ActiveRecord::Migration[5.2]
  def change
    rename_column :favourites, :my_recipe_id, :myrecipe_id
  end
end
