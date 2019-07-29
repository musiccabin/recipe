class Ingredient < ApplicationRecord

  has_many :my_recipe_ingredient_links, dependent: :destroy
  has_many :ingredients, through: :my_recipe_ingredient_links

  belongs_to :my_recipe

  validates :name, presence: true, uniqueness: true
  validates :quantity, presence: true
end
