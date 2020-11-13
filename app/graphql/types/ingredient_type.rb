module Types
  class IngredientType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    # field :myrecipeingredientlink_id, Integer, null: true
    field :category, String, null: false

    field :has, MyrecipeingredientlinkType, null: false, method: :myrecipeingredientlink
  end
end
