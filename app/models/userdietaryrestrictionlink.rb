class Userdietaryrestrictionlink < ApplicationRecord
  belongs_to :user
  belongs_to :dietaryrestriction

  validates :dietaryrestriction, uniqueness: {scope: :user}
end
