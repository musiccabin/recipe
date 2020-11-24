module Types
  class LeftoverUsageMealplanLinkType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :leftover, Types::LeftoverType, null: false
    field :mealplan, Types::MealplanType, null: false
  end
end
