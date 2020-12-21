module Mutations
    class RemoveLeftoverMutation < Mutations::BaseMutation
      argument :id, ID, required: true

      field :status, String, null: true
  
      def resolve(id:)
        check_authentication!

        leftover = Leftover.find_by(id: id)
        check_leftover_exists!(leftover)
        authenticate_item_owner!(leftover)
        leftover.destroy
        RecipeSchema.subscriptions.trigger("leftoverRemoved", {}, current_user)
        { status: 'leftover item is removed!' }
      end
    end
end