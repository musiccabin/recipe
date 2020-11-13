module Types
    class IngredientAttributes < Types::BaseInputObject
      description "Attributes for an ingredient"

      argument :ingredient_name, String, required: true
      argument :quantity, String, required: true
      argument :unit, String, required: false
    end
  end