module Mutations
    class PublishRecipeMutation < Mutations::BaseMutation
      argument :id, ID, required: true

      field :status, String, null: true
      field :errors, Types::ValidationErrorsType, null: true
  
      def resolve(id:)
        check_authentication!

        recipe = Myrecipe.find_by(id: id)
        check_recipe_exists!(recipe)
        authenticate_item_owner!(recipe)
        
        recipe.is_hidden = false
        if recipe.save
          RecipeSchema.subscriptions.trigger("recipeIsPublished", {}, recipe)
          { status: 'recipe is published!'}
        else
          { errors: recipe.errors }
        end
      end
    end
end