module Mutations
    class RemoveCompletionMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true

      field :status, String, null: false
  
      def resolve(recipe_id:)
        check_authentication!

        completion = current_user.completions&.find_by(myrecipe: recipe_id)
        # if completion&.previously_completed
        #   return { status: 'recipe is previously completed. completion removed from mealplan.' } 
        # end
        if completion.present?
            authenticate_item_owner!(completion)
            current_user.mealplan.myrecipemealplanlinks.find_by(myrecipe: recipe_id).update(completed: false)
            # completion.destroy
            # RecipeSchema.subscriptions.trigger("completionRemoved", {}, current_user)
            { status: 'completion of this recipe is removed from current mealplan!'}
        else
            raise GraphQL::ExecutionError,
                "You did not complete this recipe."
        end
      end
    end
end