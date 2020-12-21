module Mutations
    class UpdateGroceryMutation < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :attributes, Types::IngredientAttributes, required: true
  
      field :grocery, Types::GroceryType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(attributes:, id:)
        check_authentication!
        grocery = Grocery.find_by(id: id)
        check_grocery_exists!(grocery)  
        authenticate_item_owner!(grocery)
  
        if grocery.update(name: attributes.ingredient_name, quantity: attributes.quantity, unit: attributes.unit)
          RecipeSchema.subscriptions.trigger("groceryUpdated", {}, grocery)
          { grocery: grocery }
        else
          { errors: grocery.errors }
        end
      end
    end
  end