module Types
    class ProvType < Types::BaseObject
      field :prov, String, null: true
      field :cities, [String], null: true
    end
end