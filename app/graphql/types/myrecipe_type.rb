module Types
  class MyrecipeType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :cooking_time_in_min, Integer, null: false
    field :imageURL, String, null: true
    field :videoURL, String, null: true
    field :instructions, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :is_hidden, Boolean, null: false
    field :cooking_time, String, null: false
    field :avatar_file_name, String, null: true
    field :avatar_content_type, String, null: true
    field :avatar_file_size, Integer, null: true
    field :avatar_updated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :user, Types::UserType, null: false
    field :myrecipeingredientlinks, [Types::MyrecipeingredientlinkType], null: true
  end
end
