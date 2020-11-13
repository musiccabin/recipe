module Types
  class LeftoverType < Types::BaseObject
    field :id, ID, null: false
    # field :ingredient_id, Integer, null: true
    # field :user_id, Integer, null: true
    field :quantity, String, null: false
    field :unit, String, null: false
    field :expiry_date, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :belongs_to, UserType, null: false, method: :user
    field :has, IngredientType, null: false, method: :ingredient
  end
end
