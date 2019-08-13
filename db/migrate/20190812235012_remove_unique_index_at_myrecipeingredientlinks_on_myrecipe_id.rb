class RemoveUniqueIndexAtMyrecipeingredientlinksOnMyrecipeId < ActiveRecord::Migration[5.2]
  def change
    remove_index :myrecipeingredientlinks, :myrecipe_id
    add_index :myrecipeingredientlinks, :myrecipe_id
  end
end
