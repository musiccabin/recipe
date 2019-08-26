class Mealplan < ApplicationRecord
  belongs_to :user

  has_many :myrecipemealplanlinks, dependent: :destroy
  has_many :myrecipes, through: :myrecipemealplanlinks

end
