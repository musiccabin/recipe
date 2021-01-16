class Leftover < ApplicationRecord
  belongs_to :ingredient
  belongs_to :user

  # validate :accepted_expiry_date
  validate :non_negative_quantity
  validate :accepted_ingredients
  validates :ingredient, presence: true, uniqueness: {scope: :user}

  
  private
  # def accepted_expiry_date
  #   error_text = 'please follow the format of mm-dd.'
  #   input = expiry_date.gsub(/\s+/, "")
  #   if input.length <= 5
  #     mo = input.split('-')[0].to_i
  #     day = input.split('-')[1].to_i
  #     self.errors.add(:expiry_date,error_text) unless mo <= 12 && day <= 31
  #   else
  #     self.errors.add(:expiry_date,error_text)
  #   end
  # end

  def accepted_ingredients
    if ['ice cube', 'water'].include? ingredient.name.downcase
      self.errors.add(:ingredient,'we do not track leftovers for this ingredient.')
    end
  end

  def non_negative_quantity
    if (quantity.include? '-')
      self.errors.add(:quantity, 'leftover quantity cannot be negative.')
    end
  end
end
