class LeftoverUsage < ApplicationRecord
    belongs_to :user
    belongs_to :ingredient
    belongs_to :myrecipe
    has_one :leftover_usage_mealplan_link, dependent: :destroy
    has_one :mealplan, through: :leftover_usage_mealplan_link, dependent: :nullify

    validates :quantity, presence: true
end
