class Grocery < ApplicationRecord
    has_many :ingredients

    belongs_to :user

    validates :name, presence: true, uniqueness: {scope: :user}
    validates_inclusion_of :category, :in => ['produce', 'meat', 'dairy', 'frozen', 'other'], :allow_nil => true
    validate :quantity_present

    private
    def quantity_present
        if self.user_added == false
            self.errors.add(:quantity, 'quantity should be present') if self.quantity.to_s == ''
        end
    end
end
