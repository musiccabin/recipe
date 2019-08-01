class Ingredient < ApplicationRecord

  has_many :myrecipeingredientlinks, dependent: :destroy
  has_many :myrecipes, through: :myrecipeingredientlinks

  validates :name, presence: true, uniqueness: true
end
