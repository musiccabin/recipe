class Leftover < ApplicationRecord
  belongs_to :ingredient
  belongs_to :user

  # validate :accepted_expiry_date
  validate :non_negative_quantity
  validate :no_ice_cube
  validates :ingredient, uniqueness: {scope: :user}
  
  private
  def accepted_expiry_date
    error_text = 'please follow the format of mm-dd.'
    input = expiry_date.gsub(/\s+/, "")
    if input.length <= 5
      mo = input.split('-')[0].to_i
      day = input.split('-')[1].to_i
      self.errors.add(:expiry_date,error_text) unless mo <= 12 && day <= 31
    else
      self.errors.add(:expiry_date,error_text)
    end
  end

  def no_ice_cube
    if ingredient.name == 'ice cube'
      self.errors.add(:ingredient,'error: we do not track ice cubes.')
    end
  end

  def non_negative_quantity
    if (quantity.include? '-')
      self.errors.add(:quantity, 'leftover quantity cannot be negative.')
    end
  end
end
