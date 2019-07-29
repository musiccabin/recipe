class DietaryRestrictionLink < ApplicationRecord
  belongs_to :my_recipe
  belongs_to :dietary_restriction

  validates :dietary_restriction, presence: true, uniqueness: {scope: :my_recipe}
end
