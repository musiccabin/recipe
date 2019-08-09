class CompletionsColumnNameCorrections < ActiveRecord::Migration[5.2]
  def change
    rename_column :completions, :my_recipe_id, :myrecipe_id
  end
end
