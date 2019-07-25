class AddIndicesToDietaryIngredients < ActiveRecord::Migration[5.2]
  def change
    add_index :dietary_restrictions, :name
  end
end
