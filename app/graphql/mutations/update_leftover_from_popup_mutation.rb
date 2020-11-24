module Mutations
    class UpdateLeftoverFromPopupMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true
  
      field :status, String, null: true
      field :errors, [Types::ValidationErrorsType], null: true
  
      def resolve(recipe_id:)
        check_authentication!

        recipe = Myrecipe.find_by(id: recipe_id)
        if recipe.nil?
          raise GraphQL::ExecutionError,
                "Recipe not found."
        end
        if current_user.mealplan.myrecipes.exclude? recipe
          raise GraphQL::ExecutionError,
                "This action is only available for recipes in your mealplan."
        end
        links = recipe.myrecipeingredientlinks
        leftovers = current_user.leftovers
        leftover_usage_links = current_user.mealplan.leftover_usage_mealplan_links
        recipe_leftover_usages = []
        if leftover_usage_links.any?
          leftover_usage_links.each do |l|
            recipe_leftover_usages << l.leftover_usage if l.leftover_usage.myrecipe == recipe
          end
        end
        errors = []
        # byebug
        if recipe_leftover_usages.empty?
          links.each do |link|
            error = add_leftover_usage(recipe, link.ingredient, link.quantity, link.unit, nil, [])
            # byebug
            errors += error unless error.empty?
          end
        end
        { errors: errors }
        { status: 'leftovers updated according to amounts used in recipe!' }
      end
    end
end