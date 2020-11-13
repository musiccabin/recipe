module Types
  class LeftoverUsageType < Types::BaseObject
    field :id, ID, null: false
    field :quantity, String, null: false
    field :unit, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    # field :user_id, Integer, null: true
    # field :ingredient_id, Integer, null: true
    # field :myrecipe_id, Integer, null: true
    # field :mealplan_id, Integer, null: true
    # field :leftover_usage_mealplan_links_id, Integer, null: true

    field :belongs_to, UserType, null: false, method: :user
    field :belongs_to, IngredientType, null: false, method: :ingredient
    field :belongs_to, MyrecipeType, null: true, method: :myrecipe
    field :belongs_to, MealplanType, null: true, method: :mealplan
    field :has, LeftoverUsageMealplanLinkType, null: false, method: :leftover_usage_mealplan_link
  end
end
