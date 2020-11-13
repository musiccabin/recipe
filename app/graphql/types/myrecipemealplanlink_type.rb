module Types
  class MyrecipemealplanlinkType < Types::BaseObject
    field :id, ID, null: false
    # field :mealplan_id, Integer, null: true
    # field :myrecipe_id, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :belongs_to, MyrecipeType, null: false, method: :myrecipe
    field :belongs_to, MealplanType, null: false, method: :mealplan
  end
end
