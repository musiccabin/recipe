class DietaryRestriction < ApplicationRecord

    has_many :dietary_restriction_links, dependent: :destroy
    has_many :my_recipes, through: :dietary_restriction_links

    validates :name, presence: true, uniqueness: true
end
