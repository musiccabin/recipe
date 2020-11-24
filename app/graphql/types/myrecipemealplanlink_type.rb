module Types
  class MyrecipemealplanlinkType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :myrecipe, Types::MyrecipeType, null: false
    field :mealplan, Types::MealplanType, null: false
  end
end
