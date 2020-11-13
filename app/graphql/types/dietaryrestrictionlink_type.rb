module Types
  class DietaryrestrictionlinkType < Types::BaseObject
    field :id, ID, null: false
    # field :myrecipe_id, Integer, null: true
    # field :dietaryrestriction_id, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :belongs_to, MyrecipeType, null: false, method: :myrecipe
    field :belongs_to, DietaryrestrictionType, null: false, method: :dietaryrestriction
  end
end
