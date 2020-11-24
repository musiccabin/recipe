module Types
    class IngredientStatsType < Types::BaseObject
    #   field :id, ID, null: false
      field :ingredient, Types::IngredientType, null: false
      field :quantity, String, null: false
      field :unit, String, null: true
      field :count, Integer, null: false
    end
end
  