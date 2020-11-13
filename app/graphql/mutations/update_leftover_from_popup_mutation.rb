module Mutations
    class UpdateLeftoverFromPopupMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true
  
      field :status, String, null: true
      field :errors, [Types::ValidationErrorsType], null: true
  
      def resolve
        check_authentication!

        recipe = Myrecipe.find_by(id: recipe_id)
        if recipe.nil?
          raise GraphQL::ExecutionError,
                "Recipe not found."
        end
        links = recipe.myrecipeingredientlinks
        leftovers = current_user.leftovers
        leftover_usage_links = current_user.mealplan.leftover_usage_mealplan_links
        leftover_usages = []
        if leftover_usage_links.any?
          leftover_usage_links.each do |l|
            leftover_usages << l.leftover_usage if l.leftover_usage.myrecipe == recipe
          end
        end
        if leftover_usages.empty?
          links.each do |link|
            errors = add_leftover_usage(recipe, link.ingredient, link.quantity, link.unit, nil, [])
            if errors.any?
              { errors: errors }
            else
              { status: 'leftovers updated according to amounts used in recipe!'}
            end
          end
        end
      end
    end
end