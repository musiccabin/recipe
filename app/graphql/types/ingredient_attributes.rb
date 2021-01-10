module Types
    class IngredientAttributes < Types::BaseInputObject
      description "Attributes for an ingredient"

      argument :ingredient_name, String, required: true
      argument :quantity, String, required: false
      argument :unit, String, required: false
      argument :category, String, required: true
    end
  end