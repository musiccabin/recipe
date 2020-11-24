module Types
    class TopTenUsagesType < Types::BaseObject
      # field :id, ID, null: false
      field :frozen, [Types::IngredientStatsType], null: true
      field :meat, [Types::IngredientStatsType], null: true
      field :dairy, [Types::IngredientStatsType], null: true
      field :produce, [Types::IngredientStatsType], null: true
      field :nuts_and_seeds, [Types::IngredientStatsType], null: true
      field :other, [Types::IngredientStatsType], null: true
    end
end