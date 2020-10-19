class LeftoverUsage < ApplicationRecord
    belongs_to :user

    validates :quantity, presence: true
    validates :unit, presence: true
end
