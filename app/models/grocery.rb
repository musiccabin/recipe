class Grocery < ApplicationRecord

    has_many :ingredients

    belongs_to :user

    validates :name, presence: true, uniqueness: true
    # validates :quantity, presence: true
end
