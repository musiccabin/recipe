class Grocery < ApplicationRecord
    has_many :ingredients

    belongs_to :user

    validates :name, presence: true, uniqueness: {scope: :user, case_sensitive: false}
    validate :accepted_category
    # validates_inclusion_of :category, :in => ['produce', 'meat', 'dairy', 'frozen', 'other'], :allow_nil => true
    validate :quantity_present

    private
    def quantity_present
        if self.user_added == false
            self.errors.add(:quantity, 'quantity should be present') if self.quantity.to_s == ''
        end
    end

    def accepted_category
        self.errors.add(:category, 'allowed categories: produce, meat, dairy, frozen, nuts & seeds, other') unless ['produce', 'meat', 'dairy', 'frozen', 'nuts & seeds', 'other'].include? self&.category&.downcase
    end
end
