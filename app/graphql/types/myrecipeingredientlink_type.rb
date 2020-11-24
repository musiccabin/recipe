module Types
  class MyrecipeingredientlinkType < Types::BaseObject
    field :id, ID, null: false
    field :quantity, String, null: false
    field :unit, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    # field :expiry_date, GraphQL::Types::ISO8601Date, null: true
    field :myrecipe, Types::MyrecipeType, null: false
    field :ingredient, Types::IngredientType, null: false
  end
end
