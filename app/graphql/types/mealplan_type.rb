module Types
  class MealplanType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user, Types::UserType, null: false
    field :leftover_usage_mealplan_links, [Types::LeftoverUsageMealplanLinkType], null: true

  end
end
