module Mutations
    class HideRecipeMutation < Mutations::BaseMutation
      argument :id, ID, required: true

      field :status, String, null: false
  
      def resolve(id:)
        check_authentication!

        recipe = Myrecipe.find_by(id: id)
        check_recipe_exists!(recipe)        
        authenticate_recipe_owner!(recipe)

        recipe.update(is_hidden: true)
        RecipeSchema.subscriptions.trigger("recipeIsHidden", {}, recipe)
        { status: 'recipe is hidden!' }
      end
    end
end