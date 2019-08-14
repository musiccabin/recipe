class Leftover < ApplicationRecord
  belongs_to :ingredient
  belongs_to :user

  validate :accepted_expiry_date
  validates :ingredient, uniqueness: true
  
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
end
