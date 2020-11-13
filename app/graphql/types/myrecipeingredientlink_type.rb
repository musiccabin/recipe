module Types
  class MyrecipeingredientlinkType < Types::BaseObject
    field :id, ID, null: false
    # field :myrecipe_id, Integer, null: true
    # field :ingredient_id, Integer, null: true
    field :quantity, String, null: false
    field :unit, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :expiry_date, GraphQL::Types::ISO8601Date, null: true

    field :belongs_to, MyrecipeType, null: false, method: :myrecipe
    field :belongs_to, IngredientType, null: false, method: :ingredient
  end
end
