class Dietaryrestrictionlink < ApplicationRecord
  belongs_to :myrecipe
  belongs_to :dietaryrestriction

  validates :dietaryrestriction, presence: true, uniqueness: {scope: :myrecipe}
end
