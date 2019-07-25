class Tag < ApplicationRecord

    has_many :taggings, dependent: :destroy
    has_many :my_recipes, through: :taggings
end
