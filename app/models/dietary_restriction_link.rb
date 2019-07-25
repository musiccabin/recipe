class DietaryRestrictionLink < ApplicationRecord
  belongs_to :my_recipe
  belongs_to :dietary_restriction
end
