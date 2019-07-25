class MyRecipe < ApplicationRecord

    has_many :my_recipe_ingredient_links, dependent: :destroy
    has_many :ingredients, through: :my_recipe_ingredient_link
    has_many :completions, dependent: :destroy
    has_many :reviews, dependent: :destroy
    has_many :dietary_restriction_links, dependent: :destroy
    has_many :dietary_restrictions, through: :dietary_restriction_links
    has_many :taggings, dependent: :destroy
    has_many :tags, through: :taggings
end
