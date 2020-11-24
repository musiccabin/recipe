module Mutations
    class UpdateLeftoverMutation < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :attributes, Types::IngredientAttributes, required: true
  
      field :leftover, Types::LeftoverType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(id:, attributes:)
        check_authentication!
        leftover = Leftover.find_by(id: id)
        if leftover.nil?
          raise GraphQL::ExecutionError,
                "Leftover item not found."
        end

        ingredient = Ingredient.find_by(name: attributes.ingredient_name)
        if ingredient.nil?
          raise GraphQL::ExecutionError,
                "Ingredient not found."
        end
  
        if current_user != leftover.user
          raise GraphQL::ExecutionError,
                "You are not allowed to edit this leftover."
        end
  
        if leftover.update(ingredient: ingredient, quantity: attributes.quantity, unit: attributes.unit)
          RecipeSchema.subscriptions.trigger("leftoverUpdated", {}, leftover)
          { leftover: leftover }
        else
          { errors: leftover.errors }
        end
      end
    end
end