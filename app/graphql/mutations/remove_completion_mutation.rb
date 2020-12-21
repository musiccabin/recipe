module Mutations
    class RemoveCompletionMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true

      field :status, String, null: true
  
      def resolve(recipe_id:)
        check_authentication!

        completion = current_user.completions&.find_by(myrecipe: recipe_id)
        return { status: 'recipe is previously completed. completion not removed.' } if completion&.previously_completed
        if completion.present?
            authenticate_item_owner!(completion)
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