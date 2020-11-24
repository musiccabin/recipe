module Mutations
    class RemoveLeftoverMutation < Mutations::BaseMutation
      argument :id, ID, required: true

      field :status, String, null: true
  
      def resolve(id:)
        check_authentication!

        leftover = Leftover.find_by(id: id)
        if leftover.present?
          if current_user != leftover.user 
            raise GraphQL::ExecutionError,
                "You are not allowed to remove this leftover item."
          end
          leftover.destroy
          RecipeSchema.subscriptions.trigger("leftoverRemoved", {}, current_user)
          { status: 'leftover item is removed!' }
        else
          raise GraphQL::ExecutionError,
              "Leftover item not found."
        end
      end
    end
end