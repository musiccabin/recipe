module Types
  class GroceryType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :quantity, String, null: true
    field :unit, String, null: true
    field :is_completed, Boolean, null: false
    # field :user_id, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user_added, Boolean, null: false
    field :category, String, null: false

    field :belongs_to, UserType, null: false, method: :user
  end
end
