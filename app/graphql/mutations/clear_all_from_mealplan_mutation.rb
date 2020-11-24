module Mutations
    class ClearAllFromMealplanMutation < Mutations::BaseMutation
      field :status, String, null: true
  
      def resolve
        check_authentication!

        user_recipe_usages = current_user.mealplan.leftover_usages
        if user_recipe_usages
            user_recipe_usages.each do |usage|
              usage.update(mealplan: nil)
              usage.leftover_usage_mealplan_link.destroy
            end
        end
        links = current_user.mealplan.myrecipemealplanlinks
        if links
            links.each do |link|
                link.destroy
            end
        end
        add_groceries_from_mealplan
        RecipeSchema.subscriptions.trigger("clearedAllFromMealplan", {}, current_user.mealplan)
        { status: 'all recipes removed from mealplan!' }
      end
    end
end