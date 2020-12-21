module Mutations
    class RemoveUsagesMutation < Mutations::BaseMutation
      argument :recipe_id, ID, required: true

      field :status, String, null: true
      field :errors, [Types::ValidationErrorsType], null: false
  
      def resolve(recipe_id:)
        check_authentication!

        recipe = Myrecipe.find_by(id: recipe_id)
        check_recipe_exists!(recipe)

        check_recipe_in_mealplan!(recipe)

        count_usages_removed = 0
        errors = []
        current_user.mealplan.leftover_usages.each do |leftover_usage|
            if leftover_usage.myrecipe == recipe
                leftover_usage_quantity = floatify(leftover_usage.quantity)
                ingredient = leftover_usage.ingredient
                leftover = current_user.leftovers.find_by(ingredient: ingredient)
                if leftover.present?
                    leftover_quantity = floatify(leftover.quantity)
                    if leftover.unit == leftover_usage.unit
                        leftover.quantity = stringify_quantity(leftover_quantity + leftover_usage_quantity) 
                    else
                        ingredient_name = ingredient.name
                        unit_leftover = leftover.unit
                        unit_leftover_usage = leftover_usage.unit
                        appropriate_unit = appropriate_unit(ingredient_name, unit_leftover)
                        if unit_leftover_usage != appropriate_unit
                            leftover_usage_quantity = convert_quantity(ingredient_name, leftover_usage_quantity, unit_leftover_usage, appropriate_unit)
                        end
                        if unit_leftover != appropriate_unit
                            leftover.unit = appropriate_unit
                            leftover_quantity = convert_quantity(ingredient_name, leftover_quantity, unit_leftover, appropriate_unit)
                        end
                        leftover.quantity = stringify_quantity(leftover_quantity + leftover_usage_quantity)
                    end
                    if leftover.save
                        leftover.destroy if leftover.quantity == '0'
                        RecipeSchema.subscriptions.trigger("leftoverUpdated", {}, leftover) if leftover.present?
                    else
                        errors << leftover.errors
                    end
                else
                    leftover = Leftover.new(user:current_user, ingredient: ingredient, quantity: leftover_usage.quantity, unit: leftover_usage.unit)
                    if leftover.save
                        leftover.destroy if leftover.quantity == '0'
                        RecipeSchema.subscriptions.trigger("leftoverAdded", {}, leftover) if leftover.present?
                    else
                        errors << leftover.errors
                    end
                end
                leftover_usage.destroy
                count_usages_removed += 1
            end
        end
        if count_usages_removed == 0
            { status: "no ingredient usages found. please investigate!" , errors: errors }
        else
            { status: "removed #{count_usages_removed} ingredient usages!", errors: errors }
        end
      end
    end
end