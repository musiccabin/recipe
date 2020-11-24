module Mutations
    class UpdateGroceryMutation < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :attributes, Types::IngredientAttributes, required: true
  
      field :grocery, Types::GroceryType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(attributes:, id:)
        check_authentication!
        grocery = Grocery.find_by(id: id)
        if grocery.nil?
            raise GraphQL::ExecutionError,
                "Grocery item not found."
        end
  
        if current_user != grocery.user
          raise GraphQL::ExecutionError,
                "You are not allowed to edit this item."
        end
  
        if grocery.update(name: attributes.ingredient_name, quantity: attributes.quantity, unit: attributes.unit)
          RecipeSchema.subscriptions.trigger("groceryUpdated", {}, grocery)
          { grocery: grocery }
        else
          { errors: grocery.errors }
        end
      end
    end
  end