module Mutations
    class NewLeftoverMutation < Mutations::BaseMutation
      argument :attributes, Types::IngredientAttributes, required: true
  
      field :leftover, Types::LeftoverType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(attributes:)
        check_authentication!

        ingredient = Ingredient.find_by(name: attributes.ingredient_name)
        check_ingredient_exists!(ingredient)
        leftover = Leftover.new(ingredient: ingredient, quantity: attributes.quantity, unit: attributes.unit, user: current_user)
  
        if leftover.save
          RecipeSchema.subscriptions.trigger("leftoverAdded", {}, leftover)
          { leftover: leftover }
        else
          { errors: leftover.errors }
        end
      end
    end
end