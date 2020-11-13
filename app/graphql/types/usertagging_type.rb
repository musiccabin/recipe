module Types
  class UsertaggingType < Types::BaseObject
    field :id, ID, null: false
    # field :user_id, Integer, null: true
    # field :tag_id, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :belongs_to, UserType, null: false, method: :user
    field :belongs_to, TagType, null: false, method: :tag
  end
end
