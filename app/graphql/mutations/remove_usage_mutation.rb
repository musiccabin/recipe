module Mutations
    class RemoveUsageMutation < Mutations::BaseMutation
      argument :id, ID, required: true

      field :status, String, null: false
  
      def resolve(id:)
        check_authentication!

        leftover_usage = LeftoverUsage.find_by(id: id)
        check_leftover_usage_exists!(leftover_usage)
        authenticate_item_owner!(leftover_usage)
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
        { status: 'ingredient usage is removed!' }
      end
    end
end