class Myrecipeingredientlink < ApplicationRecord
  belongs_to :myrecipe
  belongs_to :ingredient

  validates: :quantity, presence: true
end
