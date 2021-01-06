module Mutations
    class RemoveLeftoverMutation < Mutations::BaseMutation
      argument :id, ID, required: true

      field :grocery_updated, Boolean, null: false
      field :status, String, null: false
  
      def resolve(id:)
        grocery_updated = false
        check_authentication!

        leftover = Leftover.find_by(id: id)
        check_leftover_exists!(leftover)
        authenticate_item_owner!(leftover)
        grocery_updated = update_grocery(leftover, true, nil, nil)
        leftover.destroy
        RecipeSchema.subscriptions.trigger("leftoverRemoved", {}, current_user)
        { status: 'leftover item is removed!', grocery_updated: grocery_updated }
      end
    end
end