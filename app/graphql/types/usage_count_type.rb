module Types
    class UsageCountType < Types::BaseObject
      # field :id, ID, null: false
      field :frozen, Integer, null: false
      field :meat, Integer, null: false
      field :dairy, Integer, null: false
      field :produce, Integer, null: false
      field :nuts_and_seeds, Integer, null: false
      field :other, Integer, null: false
    end
end