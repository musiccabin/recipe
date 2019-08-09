class ColumnNameCorrections < ActiveRecord::Migration[5.2]
  def change
    rename_column :taggings, :my_recipe_id, :myrecipe_id
  end
end
