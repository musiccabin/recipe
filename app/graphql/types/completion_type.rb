module Types
  class CompletionType < Types::BaseObject
    field :id, ID, null: false
    # field :user_id, Integer, null: true
    # field :myrecipe_id, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :user, Types::UserType, null: false
    field :myrecipe, Types::MyrecipeType, null: false
  end
end
