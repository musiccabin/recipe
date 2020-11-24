module Types
  class LeftoverType < Types::BaseObject
    field :id, ID, null: false
    field :quantity, String, null: false
    field :unit, String, null: true
    field :expiry_date, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user, Types::UserType, null: false
    field :ingredient, Types::IngredientType, null: false
  end
end
