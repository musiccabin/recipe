class Myrecipemealplanlink < ApplicationRecord
  belongs_to :mealplan
  belongs_to :myrecipe
end
