module Types
  class LeftoverUsageMealplanLinkType < Types::BaseObject
    field :id, ID, null: false
    # field :leftover_usage_id, Integer, null: true
    # field :mealplan_id, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :belongs_to, LeftoverType, null: false, method: :leftover
    field :belongs_to, MealplanType, null: false, method: :mealplan
  end
end
