class Myrecipemealplanlink < ApplicationRecord
  belongs_to :mealplan
  belongs_to :myrecipe

  validates :myrecipe, uniqueness: {scope: :mealplan}
end
