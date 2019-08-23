class Myrecipeingredientlink < ApplicationRecord
  belongs_to :myrecipe
  belongs_to :ingredient

  validates :quantity, presence: true
  validate :quantity_is_number

  private
  def quantity_is_number
    self.errors.add(:quantity, 'should be numbers or fractions only.') if self.quantity.include? '/^[A-Za-z]+$/'
  end
end
