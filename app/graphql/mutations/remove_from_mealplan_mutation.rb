module Mutations
    class RemoveFromMealplanMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true
  
      def resolve(recipe_id:)
        check_authentication!

        recipe = Myrecipe.find_by(id: myrecipe_id)
        if recipe.nil?
          raise GraphQL::ExecutionError,
                "Recipe not found."
        end
        user_recipe_usages = current_user.mealplan&.leftover_usages.where(myrecipe: recipe)
        if user_recipe_usages
          user_recipe_usages.each do |usage|
            usage.update(mealplan: nil)
            usage.leftover_usage_mealplan_link.destroy
          end
        end
        link = current_user.mealplan.myrecipemealplanlinks.find_by(myrecipe: recipe)
        link.destroy
        add_groceries_from_mealplan
        RecipeSchema.subscriptions.trigger("recipeRemovedFromMealplan", {}, current_user.mealplan)
        { status: 'recipe removed from mealplan!' }
      end
    end
end