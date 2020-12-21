module Mutations
    class PublishRecipeMutation < Mutations::BaseMutation
      argument :id, ID, required: true

      field :status, String, null: false
  
      def resolve(id:)
        check_authentication!

        recipe = Myrecipe.find_by(id: id)
        check_recipe_exists!(recipe)
        authenticate_recipe_owner!(recipe)
        
        recipe.update(is_hidden: false)
        RecipeSchema.subscriptions.trigger("recipeIsPublished", {}, recipe)
        { status: 'recipe is published!'}
      end
    end
end