module Mutations
    class NewLeftoverMutation < Mutations::BaseMutation
      argument :attributes, Types::IngredientAttributes, required: true
  
      field :leftover, Types::LeftoverType, null: true
      field :grocery_updated, Boolean, null: false
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(attributes:)
        grocery_updated = false
        check_authentication!

        ingredient_name = attributes.ingredient_name
        ingredient = Ingredient.find_or_initialize_by(name: ingredient_name)
        leftover = Leftover.new(ingredient: ingredient, quantity: attributes.quantity, unit: attributes.unit, user: current_user)
  
        if leftover.save
          RecipeSchema.subscriptions.trigger("leftoverAdded", {}, leftover)
          { leftover: leftover, grocery_updated: update_grocery(leftover, false, nil, nil) }
        else
          { errors: leftover.errors, grocery_updated: grocery_updated }
        end
      end
    end
end