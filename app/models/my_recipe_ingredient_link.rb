class MyRecipeIngredientLink < ApplicationRecord
  belongs_to :my_recipe
  belongs_to :ingredient
end
