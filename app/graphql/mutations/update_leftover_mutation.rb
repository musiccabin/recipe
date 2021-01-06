module Mutations
    class UpdateLeftoverMutation < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :attributes, Types::IngredientAttributes, required: true
  
      field :leftover, Types::LeftoverType, null: true
      field :grocery_updated, Boolean, null: false
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(id:, attributes:)
        grocery_updated = false
        check_authentication!
        leftover = Leftover.find_by(id: id)
        old_quantity = leftover.quantity
        old_unit = leftover.unit
        check_leftover_exists!(leftover)

        ingredient = Ingredient.find_by(name: attributes.ingredient_name)
        check_ingredient_exists!(ingredient)
  
        authenticate_item_owner!(leftover)
  
        if leftover.update(ingredient: ingredient, quantity: attributes.quantity, unit: attributes.unit)
          RecipeSchema.subscriptions.trigger("leftoverUpdated", {}, leftover)
          { leftover: leftover, grocery_updated: update_grocery(leftover, false, old_quantity, old_unit) }
        else
          { errors: leftover.errors, grocery_updated: grocery_updated }
        end
      end
    end
end