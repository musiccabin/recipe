module Mutations
    class HideRecipeMutation < Mutations::BaseMutation
      argument :id, ID, required: true

      field :status, String, null: false
  
      def resolve(id:)
        check_authentication!

        recipe = Myrecipe.find_by(id: id)
        if recipe.present?
          if current_user != recipe.user 
            raise GraphQL::ExecutionError,
                "You are not allowed to remove this recipe."
          end
          recipe.update(is_hidden: true)
          RecipeSchema.subscriptions.trigger("recipeIsHidden", {}, recipe)
          { status: 'recipe is hidden!' }
        else
          raise GraphQL::ExecutionError,
              "Recipe not found."
        end
      end
    end
end