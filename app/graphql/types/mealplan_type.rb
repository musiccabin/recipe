module Types
  class MealplanType < Types::BaseObject
    field :id, ID, null: false
    # field :user_id, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    # field :leftover_usage_mealplan_links_id, Integer, null: true

    field :belongs_to, UserType, null: false, method: :user
    field :has, LeftoverUsageMealplanLinkType, null: false, method: :leftover_usage_mealplan_links

  end
end
