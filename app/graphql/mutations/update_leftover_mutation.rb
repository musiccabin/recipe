module Mutations
    class UpdateLeftoverMutation < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :attributes, Types::IngredientAttributes, required: true
  
      field :leftover, Types::LeftoverType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(id:, attributes:)
        check_authentication!
        leftover = Leftover.find_by(id: id)
        check_leftover_exists!(leftover)

        ingredient = Ingredient.find_by(name: attributes.ingredient_name)
        check_ingredient_exists!(ingredient)
  
        authenticate_item_owner!(leftover)
  
        if leftover.update(ingredient: ingredient, quantity: attributes.quantity, unit: attributes.unit)
          RecipeSchema.subscriptions.trigger("leftoverUpdated", {}, leftover)
          { leftover: leftover }
        else
          { errors: leftover.errors }
        end
      end
    end
end