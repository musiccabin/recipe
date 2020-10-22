class LeftoverUsageMealplanLink < ApplicationRecord
    belongs_to :leftover_usage
    belongs_to :mealplan
end
