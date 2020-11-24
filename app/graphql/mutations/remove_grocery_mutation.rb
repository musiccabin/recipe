module Mutations
    class RemoveGroceryMutation < Mutations::BaseMutation
      argument :id, ID, required: true

      field :status, String, null: true
  
      def resolve(id:)
        check_authentication!

        grocery = Grocery.find_by(id: id)
        if grocery.present?
          if current_user != grocery.user 
            raise GraphQL::ExecutionError,
                "You are not allowed to remove this grocery item."
          end
          grocery.destroy
          RecipeSchema.subscriptions.trigger("groceryRemoved", {}, current_user)
          { status: 'grocery item is removed!' }
        else
          raise GraphQL::ExecutionError,
              "Grocery item not found."
        end
      end
    end
end