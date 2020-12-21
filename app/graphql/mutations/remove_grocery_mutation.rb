module Mutations
    class RemoveGroceryMutation < Mutations::BaseMutation
      argument :id, ID, required: true

      field :status, String, null: true
  
      def resolve(id:)
        check_authentication!

        grocery = Grocery.find_by(id: id)
        check_grocery_exists!(grocery)
        authenticate_item_owner!(grocery)
        grocery.destroy
        RecipeSchema.subscriptions.trigger("groceryRemoved", {}, current_user)
        { status: 'grocery item is removed!' }
      end
    end
end