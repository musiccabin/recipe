class ReviewsColumnNameCorrections < ActiveRecord::Migration[5.2]
  def change
    rename_column :reviews, :my_recipe_id, :myrecipe_id
  end
end
