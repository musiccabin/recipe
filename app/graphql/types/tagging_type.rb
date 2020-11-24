module Types
  class TaggingType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :myrecipe, Types::MyrecipeType, null: false
    field :tags, [Types::TagType], null: false
  end
end
