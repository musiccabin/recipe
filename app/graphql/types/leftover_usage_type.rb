module Types
  class LeftoverUsageType < Types::BaseObject
    field :id, ID, null: false
    field :quantity, String, null: false
    field :unit, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user, Types::UserType, null: false
    field :ingredient, Types::IngredientType, null: false
    field :myrecipe, Types::MyrecipeType, null: true
    field :mealplan, Types::MealplanType, null: true
    field :leftover_usage_mealplan_link, Types::LeftoverUsageMealplanLinkType, null: false
  end
end
