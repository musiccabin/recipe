class Ingredient < ApplicationRecord

  has_many :myrecipeingredientlinks, dependent: :destroy
  has_many :myrecipes, through: :myrecipeingredientlinks
  has_one :quantity, through: :myrecipeingredientlinks, scope: :myrecipe
  has_one :unit, through: :myrecipeingredientlinks, scope: :myrecipe

  validates :name, presence: true, uniqueness: true
end
