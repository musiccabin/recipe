class RemoveMyrecipeReferencesFromMealplans < ActiveRecord::Migration[5.2]
  def change
    remove_reference :mealplans, :myrecipe, foreign_key: true
  end
end
