module Mutations
    class RemoveCompletionMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true

      field :status, String, null: true
  
      def resolve(recipe_id:)
        check_authentication!

        completion = current_user.completions&.find_by(myrecipe: recipe_id)
        if completion.present?
            if current_user != completion.user 
                raise GraphQL::ExecutionError,
                    "You are not allowed to edit this completion."
            end
            completion.destroy
            RecipeSchema.subscriptions.trigger("completionRemoved", {}, current_user)
            { status: 'completion of this recipe is removed!'}
        else
            raise GraphQL::ExecutionError,
                "You did not complete this recipe."
        end
      end
    end
end