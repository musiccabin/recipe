module Mutations
    class PublishRecipeMutation < Mutations::BaseMutation
      argument :id, ID, required: true
  
      def resolve(id:)
        check_authentication!

        recipe = Myrecipe.find_by(id: id)
        if recipe.present?
          if current_user != recipe.user 
            raise GraphQL::ExecutionError,
                "You are not allowed to remove this recipe."
          end
          recipe.is_hidden = false
          RecipeSchema.subscriptions.trigger("recipeIsPublished", {}, recipe)
          { status: 'recipe is published!'}
        else
          raise GraphQL::ExecutionError,
              "Recipe not found."
        end
      end
    end
end