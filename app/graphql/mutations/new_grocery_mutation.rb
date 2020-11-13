module Mutations
    class NewGroceryMutation < Mutations::BaseMutation
      argument :attributes, Types::IngredientAttributes, required: true
  
      field :grocery, Types::GroceryType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(attributes:)
        check_authentication!
  
        grocery = Grocery.new(attributes.to_h.merge(user: current_user))
  
        if grocery.save
          RecipeSchema.subscriptions.trigger("groceryAdded", {}, grocery)
          { grocery: grocery }
        else
          { errors: grocery.errors }
        end
      end
    end
  end