module Mutations
    class UpdateUsageMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true
      argument :attributes, Types::IngredientAttributes, required: true
  
      field :status, String, null: true
      field :errors, [Types::ValidationErrorsType], null: true
      field :warning_ingredients, [String], null: true
  
      def resolve(attributes:, recipe_id:)
        check_authentication!

        recipe = Myrecipe.find_by(id: recipe_id)
        check_recipe_exists!(recipe)

        errors = []
        warning_ingredients = []

        # leftover_usage = LeftoverUsage.new(user: current_user)
        ingredient = Ingredient.find_or_initialize_by(name: attributes.ingredient_name)
        ingredient.update(category: attributes.category) unless ingredient.category.present?          
        # leftover_usage.ingredient = ingredient
        old_usage = current_user.mealplan.leftover_usages.find_by(ingredient: ingredient, myrecipe: recipe)
        all_errors = add_leftover_usage(recipe, ingredient, attributes.quantity, attributes.unit, old_usage&.quantity, old_usage&.unit, [], warning_ingredients)
        errors += all_errors[:errors]
        warning_ingredients += all_errors[:warning_ingredients]
        old_usage.destroy if old_usage.present?
        RecipeSchema.subscriptions.trigger("leftoverUsageRemoved", {}, current_user)
        if errors.any?
            { errors: errors }
        else
            { status: 'usages updated!', warning_ingredients: warning_ingredients }
        end
      end
    end
end