module Mutations
    class RemoveFromMealplanMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true

      field :status, String, null: true
  
      def resolve(recipe_id:)
        check_authentication!

        recipe = Myrecipe.find_by(id: recipe_id)
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
        # byebug
        existing_completion = current_user.completions&.find_by(myrecipe: recipe)
        existing_completion.update(previously_completed: true) if existing_completion
        link = current_user.mealplan.myrecipemealplanlinks.find_by(myrecipe: recipe)
        if link.present?
          link.destroy
          add_groceries_from_mealplan
          RecipeSchema.subscriptions.trigger("recipeRemovedFromMealplan", {}, current_user.mealplan)
          { status: 'recipe removed from mealplan!' }
        else
          { status: 'this recipe was not in your mealplan.'}
        end
      end
    end
end