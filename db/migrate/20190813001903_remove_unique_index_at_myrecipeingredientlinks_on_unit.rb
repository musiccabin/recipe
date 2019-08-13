class RemoveUniqueIndexAtMyrecipeingredientlinksOnUnit < ActiveRecord::Migration[5.2]
  def change
    remove_index :myrecipeingredientlinks, :unit
    add_index :myrecipeingredientlinks, :unit
  end
end
