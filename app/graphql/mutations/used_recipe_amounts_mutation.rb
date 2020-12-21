module Mutations
    class UsedRecipeAmountsMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true
  
      field :status, String, null: true
      field :errors, [Types::ValidationErrorsType], null: true
      field :warning_ingredients, [String], null: true
  
      def resolve(recipe_id:)
        check_authentication!

        recipe = Myrecipe.find_by(id: recipe_id)
        check_recipe_exists!(recipe)
        
        check_recipe_in_mealplan!(recipe)

        links = recipe.myrecipeingredientlinks
        leftovers = current_user.leftovers
        leftover_usage_links = current_user.mealplan.leftover_usage_mealplan_links
        recipe_leftover_usages = []
        if leftover_usage_links.any?
          leftover_usage_links.each do |l|
            # byebug
            recipe_leftover_usages << l.leftover_usage if l.leftover_usage.myrecipe == recipe
          end
        end
        errors = []
        warning_ingredients = []
        if recipe_leftover_usages.empty?
          links.each do |link|
            error = add_leftover_usage(recipe, link.ingredient, link.quantity, link.unit, nil, nil, [], warning_ingredients)
            # byebug
            errors += error unless error.empty?
          end
          { errors: errors, status: 'leftovers updated according to amounts used in recipe!', warning_ingredients: warning_ingredients }
        end
        # byebug
      end
    end
end