class Mealplan < ApplicationRecord
  belongs_to :myrecipe
  belongs_to :user
end
