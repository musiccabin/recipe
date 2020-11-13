module Types
  class UserdietaryrestrictionlinkType < Types::BaseObject
    field :id, ID, null: false
    # field :user_id, Integer, null: true
    # field :dietaryrestriction_id, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :belongs_to, UserType, null: false, method: :user
    field :belongs_to, DietaryrestrictionType, null: false, method: :dietaryrestriction
  end
end
