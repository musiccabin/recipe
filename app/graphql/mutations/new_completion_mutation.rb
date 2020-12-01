module Mutations
    class NewCompletionMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true

      field :completion, Types::CompletionType, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(recipe_id:)
        check_authentication!
  
        myrecipe = Myrecipe.find_by(id: recipe_id)
        if myrecipe.nil?
          raise GraphQL::ExecutionError,
                "Recipe not found."
        end
  
        completion = Completion.new(myrecipe: myrecipe, user: current_user)
        if completion.save
          RecipeSchema.subscriptions.trigger("completionAdded", {}, completion)
          { completion: completion }
        else
          { errors: completion.errors }
        end
      end
    end
end