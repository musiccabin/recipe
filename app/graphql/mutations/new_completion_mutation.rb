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

        current_user.mealplan.myrecipemealplanlinks.find_by(myrecipe: recipe).update(completed: true)
        completion_exists = current_user.completions&.find_by(myrecipe: recipe)
        if completion_exists        
          return { status: 'recipe has been completed before.' }
        else
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
end