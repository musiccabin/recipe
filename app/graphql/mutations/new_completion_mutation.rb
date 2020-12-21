module Mutations
    class NewCompletionMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true

      field :status, String, null: true
      field :completion, Types::CompletionType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(recipe_id:)
        check_authentication!
  
        recipe = Myrecipe.find_by(id: recipe_id)
        check_recipe_exists!(recipe)
  
        completion_exists = current_user.completions&.find_by(myrecipe: recipe)
        return { status: 'recipe has been completed before.' } if completion_exists
        completion = Completion.new(myrecipe: recipe, user: current_user)
        if completion.save
          RecipeSchema.subscriptions.trigger("completionAdded", {}, completion)
          { completion: completion }
        else
          { errors: completion.errors }
        end
      end
    end
end