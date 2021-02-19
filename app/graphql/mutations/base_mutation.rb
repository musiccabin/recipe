module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    def check_authentication!
      return if context[:current_user]

      raise GraphQL::ExecutionError,
            "You need to authenticate to perform this action"
    end

    def current_user
      return context[:current_user]
    end

    def check_recipe_exists!(recipe)
      if recipe.nil?
        raise GraphQL::ExecutionError,
              "Recipe not found."
      end
    end

    def check_ingredient_exists!(ingredient)
      if ingredient.nil?
        raise GraphQL::ExecutionError,
              "Ingredient not found."
      end
    end

    def check_leftover_exists!(leftover)
      if leftover.nil?
        raise GraphQL::ExecutionError,
              "Leftover item not found."
      end
    end

    def check_leftover_usage_exists!(leftover_usage)
      if leftover_usage.nil?
        raise GraphQL::ExecutionError,
              "Usage item not found."
      end
    end

    def check_grocery_exists!(grocery)
      if grocery.nil?
        raise GraphQL::ExecutionError,
              "Grocery item not found."
      end
    end

    def check_recipe_in_mealplan!(recipe)
      if current_user.mealplan.myrecipes.exclude? recipe
        raise GraphQL::ExecutionError,
              "This action is only available for recipes in your mealplan."
      end
    end

    def authenticate_item_owner!(item)
      if current_user != item.user 
        raise GraphQL::ExecutionError,
            "You are not allowed to manage this item."
      end
    end

    def add_groceries_from_mealplan
      links = []
      added_up = []
      current_user.mealplan.myrecipemealplanlinks.each do |link|
        links += link.myrecipe.myrecipeingredientlinks.to_a
      end
      links.each do |link|
        next if link.ingredient.name == 'water'
        next if link.ingredient.name == 'ice cube'
        ingredient_name = link.ingredient.name
        unit = link.unit
        appropriate_unit = appropriate_unit(ingredient_name, unit)
        found = added_up.detect {|stat| stat[:name] == ingredient_name}
        if found
          if found[:unit].to_s == ''
            found[:unit] = appropriate_unit
          elsif found[:unit] != appropriate_unit
            appropriate_unit = found[:unit]
          end
          found[:quantity] += convert_quantity(ingredient_name, link.quantity, unit, appropriate_unit)
        else
          added_up << { name: ingredient_name, quantity: convert_quantity(ingredient_name, link.quantity, unit, appropriate_unit), unit: appropriate_unit, category: link.ingredient.category }
        end
      end
  
      # subtract_leftovers
      added_up.each do |stats|
        # byebug
        ingredient = Ingredient.find_by(name: stats[:name])
        leftover = current_user.leftovers&.find_by(ingredient: ingredient)
        if leftover
          ingredient_name = ingredient.name
          stats[:quantity] -= convert_quantity(ingredient_name, leftover.quantity, leftover.unit, stats[:unit]) unless stats[:quantity].to_s == '' && is_seasoning?(ingredient_name)
          # added_up.delete(stats) if stats[:quantity] <= 0
        end
      end
  
      current_user.groceries.where(:user_added => false).destroy_all
  
      added_up.each do |stats|
        if stats[:quantity] != nil
          if ['cup', 'tbsp', 'tsp'].include?(stats[:unit])
            converted = cup_tbsp_tsp(stats[:quantity], stats[:unit])
            stats[:unit] = converted[:unit]
            stats[:quantity] = stringify_quantity(converted[:quantity])
          elsif ['kg', 'g'].include?(stats[:unit])
            converted = kg_g(stats[:quantity], stats[:unit])
            stats[:unit] = converted[:unit]
            stats[:quantity] = stringify_quantity(converted[:quantity])
          elsif ['lb', 'oz'].include?(stats[:unit])
            converted = lb_oz(stats[:quantity], stats[:unit])
            stats[:unit] = converted[:unit]
            stats[:quantity] = stringify_quantity(converted[:quantity])
          end
        end
        
        user_already_added = current_user.groceries.find_by(name: stats[:name])
        if user_already_added
          existing_unit = user_already_added.unit
          existing_quantity = user_already_added.quantity
          appropriate_unit = appropriate_unit(stats[:name], existing_unit)
          stats[:unit] = appropriate_unit
          existing_quantity = '0' if existing_quantity.to_s == ''
          stats[:quantity] += convert_quantity(stats[:name], existing_quantity, existing_unit, appropriate_unit)
          stats[:quantity] = stringify_quantity(stats[:quantity])
          user_already_added.update(user_added: false)
        else
          new_grocery = Grocery.create(name: stats[:name], quantity: stringify_quantity(stats[:quantity]), unit: stats[:unit], category: stats[:category], user: current_user, is_completed: false)
          new_grocery.destroy if new_grocery.quantity == '0'
        end
      end
    end

    def floatify(quantity)
      return quantity if quantity.is_a? Float
      output = 0
      quantity = quantity.to_s.lstrip.reverse.lstrip.reverse
      if quantity.include? ' '
        output += quantity.split(" ")[0].to_i
        to_process = quantity.split(" ")[1]
      else
        to_process = quantity
      end
      if to_process.include? '/'
        output += (to_process.split("/")[0].to_f / to_process.split("/")[1].to_f)
      else
        output += to_process.to_f
      end
      output
    end

    def stringify_quantity(float)
      float = floatify (float) unless float.is_a? Float
      return '0' if float <= 0
      output = ''
      if float != nil
        if float.floor == float
          output += float.floor.to_s
        else
          num = float - float.floor
          if float.floor == 0
            case true
            when num >= (0.875)
              output += float.ceil.to_s
            when num >= (0.7)
              output += "3/4"
            when num >= (0.6)
              output += "2/3"
            when num >= (0.4)
              output += "1/2"
            when num >= (0.29)
              output += "1/3"
            when num >= (0.2)
              output += "1/4"
            else
              output += ''
            end
          else
            case true
            when num >= (0.875)
              output += float.ceil.to_s
            when num >= (0.7)
              output += "#{float.floor.to_s} 3/4"
            when num >= (0.6)
              output += "#{float.floor.to_s} 2/3"
            when num >= (0.4)
              output += "#{float.floor.to_s} 1/2"
            when num >= (0.29)
              output += "#{float.floor.to_s} 1/3"
            when num >= (0.125)
              output += "#{float.floor.to_s} 1/4"
            else
              output += ''
            end
          end
        end
      end
      output
    end

    # def calculated_quantity(link)
    #   output = nil
    #   return output if is_seasoning?(link.ingredient.name)
    #   if link.unit == appropriate_unit(link.ingredient, link.unit)
    #       output = floatify(link.quantity)
    #   elsif link.unit == 'cup'
    #     case link.ingredient.name
    #     when 'green bell pepper'
    #       output = floatify(link.quantity) / 1.25
    #     when 'red bell pepper'
    #       output = floatify(link.quantity) / 1.25
    #     when 'yellow bell pepper'
    #       output = floatify(link.quantity) / 1.25
    #     when 'green onion'
    #       output = floatify(link.quantity) * 9
    #     when 'strawberry'
    #       output = floatify(link.quantity) * 8
    #     when 'cucumber'
    #       output = floatify(link.quantity) / 2
    #     when 'avocado'
    #       output = floatify(link.quantity) / 2
    #     when 'red onion'
    #       output = floatify(link.quantity) * 3
    #     else
    #       output = floatify(link.quantity)
    #     end
    #   elsif link.unit == 'tbsp'
    #     output = floatify(link.quantity) * 0.0625
    #   elsif link.unit == 'tsp'
    #     output = floatify(link.quantity) * 0.0625 * 0.333
    #   end
    #   output = nil if output == 0
    #   output
    # end

    def is_produce?(item)
      produce = [
        'avocado',
        'banana',
        'cilantro',
        'corn',
        'cucumber',
        'egg',
        'garlic',
        'green bell pepper',
        'green onion',
        'jalapeno',
        'mushroom',
        'onion',
        'red chili pepper',
        'red onion',
        'strawberry',
        'tomato',
        'yellow onion'
        ]
  
      produce.include? item
    end

    def is_seasoning?(item)
      seasoning = ['black pepper', 'cayenne pepper', 'oregano', 'salt']
  
      seasoning.include? item
    end

    def is_countable?(item)
      countable = ['chicken breast', 'chicken thigh']
  
      countable.include? item
    end

    def add_leftover_usage(recipe, ingredient, quantity, unit, old_usage_quantity, old_usage_unit, errors, warning_ingredients)
      ingredient_name = ingredient.name
      old_usage_exists = old_usage_quantity.present?

      # if user bought this ingredient, find it
      grocery = current_user.groceries.find_by(name: ingredient_name)
      unit_grocery = grocery&.unit
      grocery_exists = grocery.present? ? true : false
      quantity_bought = grocery_exists ? floatify(grocery.quantity) : 0

      # if user has leftovers of this ingredient, find it
      leftover = current_user.leftovers&.find_by(ingredient: ingredient)
      leftover_exists = leftover.present? ? true : false
      unit_leftover = leftover_exists ? leftover.unit.to_s : nil

      # if units are all consistent, don't need to convert unit
      should_convert_unit = true
      units = []
      units << old_usage_unit if old_usage_exists
      units << unit_grocery if grocery_exists
      units << unit_leftover if leftover_exists
      units << unit.to_s
      should_convert_unit = false if units.uniq.size <= 1

      # convert quantities if needed
      if should_convert_unit
        # unit to convert to: if old usage is present: old_usage_unit; otherwise, appropriate_unit
        if old_usage_unit.present?
          appropriate_unit = old_usage_unit
        else
          appropriate_unit = appropriate_unit(ingredient_name, unit)
        end

        quantity_used = convert_quantity(ingredient_name, quantity, unit, appropriate_unit)
        quantity_bought = grocery_exists ? convert_quantity(ingredient_name, quantity_bought, unit_grocery, appropriate_unit) : 0
        quantity_leftover = leftover_exists ? convert_quantity(ingredient_name, leftover.quantity, unit_leftover, appropriate_unit) : 0
      else
        appropriate_unit = unit
        quantity_used = floatify(quantity)
        quantity_bought = grocery_exists ? floatify(grocery.quantity) : 0
        quantity_leftover = leftover_exists ? floatify(leftover.quantity) : 0
      end

      # user has used from leftovers but did not update accurate leftovers info in the app
      if old_usage_exists
        warning_ingredients << ingredient_name if floatify(old_usage_quantity) + quantity_leftover < quantity_used
      else
        warning_ingredients << ingredient_name if quantity_leftover + quantity_bought < quantity_used
      end

      # update leftover if leftover exists
      if leftover_exists
        if old_usage_exists
          leftover.quantity = stringify_quantity(floatify(old_usage_quantity) + quantity_leftover - quantity_used)
        else
          leftover.quantity = stringify_quantity(quantity_bought + quantity_leftover - quantity_used)
        end
      # create new leftover if leftover doesn't exist
      else
        leftover = Leftover.new(user: current_user)
        leftover.ingredient = ingredient
        if old_usage_exists
          leftover.quantity = stringify_quantity(floatify(old_usage_quantity) - quantity_used)          
        else
          leftover.quantity = stringify_quantity(quantity_bought - quantity_used)
        end
      end
      leftover.unit = appropriate_unit

      # optimize leftover unit and convert quantity if needed
      if ['cup', 'tbsp', 'tsp'].include? appropriate_unit
        converted = cup_tbsp_tsp(floatify(leftover.quantity), appropriate_unit)
        leftover.unit = converted[:unit]
        leftover.quantity = stringify_quantity(converted[:quantity])
      elsif ['kg', 'g'].include? appropriate_unit
        converted = kg_g(floatify(leftover.quantity), appropriate_unit)
        leftover.unit = converted[:unit]
        leftover.quantity = stringify_quantity(converted[:quantity])
      elsif ['lb', 'oz'].include? appropriate_unit
        converted = lb_oz(floatify(leftover.quantity), appropriate_unit)
        leftover.unit = converted[:unit]
        leftover.quantity = stringify_quantity(converted[:quantity])
      end

      if leftover.save
        if ['', '0'].include?(leftover.quantity)
          leftover.destroy
        else
          if leftover_exists
            RecipeSchema.subscriptions.trigger("leftoverUpdated", {}, leftover)
          else
            RecipeSchema.subscriptions.trigger("leftoverAdded", {}, leftover)
          end
        end
      else
        errors << leftover.errors
      end

      # create leftover usage
      leftover_usage = LeftoverUsage.new(user: current_user, ingredient: ingredient, quantity: quantity, unit: unit, myrecipe: recipe)
      if leftover_usage.save
        if leftover_usage.quantity == '0'
          leftover_usage.destroy 
        else
          RecipeSchema.subscriptions.trigger("leftoverUsageAdded", {}, leftover_usage)
          usage_link = LeftoverUsageMealplanLink.new(mealplan: current_user.mealplan, leftover_usage: leftover_usage)
          usage_link.save
          leftover_usage.update(mealplan: current_user.mealplan, leftover_usage_mealplan_link: usage_link)
        end
      else
        errors << leftover_usage.errors
      end

      # return any validation errors and warning ingredients
      { errors: errors, warning_ingredients: warning_ingredients }
    end

    def add_ingredients_to_recipe(recipe, ingredients)
      ingredients.each do |i|
        if i.quantity.to_s == ''
          raise GraphQL::ExecutionError,
                "Ingredient must have a quantity. Please enter 'to taste' for seasoning."
        end
        ingredient = Ingredient.find_or_initialize_by(name: i.ingredient_name)
        ingredient.update(category: i.category) unless ingredient.category.present?
        existing_link = recipe.myrecipeingredientlinks.find_by(ingredient: ingredient)
        if existing_link
          return existing_link.errors.full_messages unless existing_link.update(quantity: i.quantity, unit: i.unit)
        else
          link = Myrecipeingredientlink.new(quantity: i.quantity, unit: i.unit)
          link.myrecipe = recipe
          link.ingredient = ingredient
          return link.errors.full_messages unless link.save
        end
      end
    end

    def update_grocery(leftover, remove_leftover, old_quantity, old_unit)
      grocery_updated = false
      ingredient = leftover.ingredient
      ingredient_name = ingredient.name
      grocery = current_user.groceries.find_by(name: ingredient_name)

      # corresponding grocery item doesn't exist && leftover being removed:
      if grocery.nil? && remove_leftover
        links = current_user.mealplan.myrecipemealplanlinks.where(completed: false)
        links.each do |link|
          link.myrecipe.myrecipeingredientlinks.each do |ingredient_link|
            if ingredient_link.ingredient == ingredient
              grocery_updated = true
              break
            end
          end
        end
        # byebug
        Grocery.create(user: current_user, name: ingredient_name, quantity: leftover.quantity, unit: leftover.unit) if grocery_updated
        return grocery_updated
      end

      # corresponding grocery item exists && hasn't been purchased yet:
      if grocery&.is_completed == false
        grocery_updated = true
        unit_grocery = grocery.unit
        appropriate_unit = nil
        quantity_to_buy = floatify(grocery.quantity)
        quantity_leftover = floatify(leftover.quantity)
        if unit_grocery != leftover.unit
          appropriate_unit = appropriate_unit(ingredient_name, unit_grocery)
          if unit_grocery != appropriate_unit
            quantity_to_buy = convert_quantity(ingredient_name, floatify(grocery.quantity), unit_grocery, appropriate_unit)
          end
          unit_leftover = leftover.unit
          if unit_leftover != appropriate_unit
            quantity_leftover = convert_quantity(ingredient_name, floatify(leftover.quantity), unit_leftover, appropriate_unit)
          end         
        end
        if unit_grocery != old_unit
          old_quantity = convert_quantity(ingredient_name, floatify(old_quantity), old_unit, appropriate_unit)
        end
        if remove_leftover
          grocery.quantity = stringify_quantity(quantity_to_buy + quantity_leftover)
        elsif old_quantity && old_unit
          grocery.quantity = stringify_quantity(quantity_to_buy + old_quantity - quantity_leftover)
        else
          grocery.quantity = stringify_quantity(quantity_to_buy - quantity_leftover)
        end 
        grocery.save
        grocery.destroy if grocery.quantity == '0'
      end
      grocery_updated
    end

    def appropriate_unit(name, unit)
      output = unit
  
      if is_produce?(name) || is_countable?(name)
        output = ''
    # else
    #     output ||= 'cup'
      end
      
      case name
      when 'almond milk'
        output = 'cup'
      when 'baby spinach'
        output = 'cup'
      when 'bacon'
        output = 'strip'
      when 'butter'
        output = 'kg'
      when 'butter lettuce'
        output = 'head'
      when 'chashu pork'
        output = 'slice'
      when 'cheddar cheese'
        output = 'kg'
      when 'chicken bouillon'
        output = 'cube'
      when 'cilantro'
        output = 'bunch'
      when 'corn'
          output = 'ear'
      when 'dried shiitaki mushroom'
        output = ''
      when 'frozen corn'
        output = 'kg'
      when 'garlic'
        output = 'clove'
      when 'ginger'
        output = 'slice'
      when 'green bean'
        output = 'kg'
      when 'ground oat'
        output = 'kg'
      when 'heavy cream'
        output = 'cup'
      when 'kidney bean'
        output = 'kg'
      when 'linguine'
        output = 'pkg'
      when 'milk'
        output = 'cup'
      when 'mozzarella cheese'
        output = 'kg'
      when 'peanut'
          output = 'cup'
      when 'peeled shrimp'
        output = 'kg'
      when 'raisin'
        output = 'kg'
      when 'ramen noodle'
        output = 'bowl'
      when 'shrimp'
        output = 'kg'
      when 'sirloin steak'
        output = 'kg'
      when 'spinach'
        output = 'cup'
      when 'whipping cream'
        output = 'cup'
      end
  
      output
    end

    def kg_to_lb (num_in_kg)
      result = num_in_kg / 0.453592
      result < 1 ? result.round(2) : result.round(1)
    end

    def lb_to_kg (num_in_lb)
      result = num_in_lb * 0.453592
      result < 1 ? result.round(2) : result.round(1)
    end

    def convert_quantity(name, quantity, unit_input, unit_output)
      return 0 if ['to taste', ''].include? quantity.to_s
      output = floatify(quantity)
      
      if unit_input == 'oz'
        in_kg = output * 0.0283495
        return unit_output == 'kg' ? in_kg : convert_quantity(name, in_kg, 'kg', unit_output)
      end

      if unit_input == 'cup'
        case unit_output
        when ''
          case name
          when 'avocado'
            output /= 2
          when 'carrot'
            output *= 2
          when 'cucumber'
            output /= 2
          when 'dried shiitaki mushroom'
            output *= (8/3)
          when 'green bell pepper'
            output
          when 'green onion'
            output *= 9
          when 'kidney bean'
            output 
          when 'mushroom'
            output *= 4.5
          when 'onion'
            output *= 3
          when 'red bell pepper'
            output
          when 'red onion'
            output *= 3
          when 'strawberry'
            output *= 8
          when 'yellow bell pepper'
            output
          end

        when 'bunch'
          case name
          when 'cilantro'
            output
          end

        when 'clove'
          output *= 48

        # when 'lb'
          # case name
          # when 'baby spinach'
          #   output = kg_to_lb(output * 0.03)
          # when 'ground oat'
          #   output = kg_to_lb(output * 0.088)
          # when 'sirloin steak'
          #   output /= 2
          # when 'spinach'
          #   output = kg_to_lb(output * 0.03)
          # end

        when 'kg'
          case name
          # when 'baby spinach'
          #   output *= 0.03
          when 'butter'
            output *= 0.227
          when 'cheddar cheese'
            output *= 0.113
          when 'firm tofu'
            output *= 0.2520273
          when 'frozen corn'
            output *= 0.165
          when 'ground oat'
            output *= 0.088
          when 'kidney bean'
            output = lb_to_kg(output / 6.5)
          when 'mozzarella cheese'
            output *= 0.113
          when 'raisin'
            output *= 0.15
          when 'sirloin steak'
            output = lb_to_kg(output / 2)
          # when 'spinach'
          #   output *= 0.03
          end

        when 'slice'
          case name
          when 'ginger'
            output = output * 3 * 48
          end

        when 'tbsp'
          output *= 16

        when 'tsp'
          output *= 48
        end
      end
  
      if unit_input == 'tbsp'
        case unit_output
        when ''
          case name
          when 'avocado'
            output = output / 2 / 16
          when 'carrot'
            output = output * 2 / 16
          when 'cucumber'
            output = output / 2 / 16
          when 'dried shiitaki mushroom'
            output = output * (8/3) / 16
          when 'green bell pepper'
            output /= 16
          when 'green onion'
            output = output * 9 / 16
          when 'mushroom'
            output = output * 4.5 / 16
          when 'onion'
            output = output * 3 / 16
          when 'red bell pepper'
            output /= 16
          when 'red onion'
            output = output * 3 / 16
          when 'strawberry'
            output = output * 8 / 16
          when 'yellow bell pepper'
            output /= 16
          end

        when 'bunch'
          case name
          when 'cilantro'
            output /= 16
          end

        when 'clove'
          output *= 3

        when 'slice'
          case name
          when 'ginger'
            output = output * 3 * 3
          end

        # when 'lb'
          # case name
          # when 'baby spinach'
          #   output = kg_to_lb(output * 0.03 / 16)
          # when 'sirloin steak'
          #   output = output / 2 / 16
          # when 'spinach'
          #   output = kg_to_lb(output * 0.03 / 16)
          # end

        when 'kg'
          case name
          # when 'baby spinach'
          #   output = output * 0.03 / 16
          when 'butter'
            output = output * 0.227 / 16
          when 'cheddar cheese'
            output = output * 0.113 / 16
          when 'firm tofu'
            output = output * 0.2520273 / 16
          when 'frozen corn'
          output = output * 0.165 / 16
          when 'ground oat'
            output = output * 0.088 / 16
          when 'kidney bean'
            output = lb_to_kg(output / 6.5 / 16)
          when 'mozzarella cheese'
            output = output * 0.113 / 16
          when 'raisin'
            output = output * 0.15 / 16
          when 'sirloin steak'
            output = lb_to_kg(output / 2 / 16)
          # when 'spinach'
          #   output = output * 0.03 / 16
          end

        when 'cup'
          output /= 16

        when 'tsp'
          output *= 3
        end
      end
  
      if unit_input == 'tsp'
        case unit_output
        when ''
          case name
          when 'avocado'
            output = output / 2 / 48
          when 'carrot'
            output = output * 2 / 48
          when 'cucumber'
            output = output / 2 / 48
          when 'dried shiitaki mushroom'
            output = output * (8/3) / 48
          when 'green bell pepper'
            output /= 48
          when 'green onion'
            output = output * 9 / 48
          when 'mushroom'
            output = output * 4.5 / 48
          when 'onion'
            output = output * 3 / 48
          when 'red bell pepper'
            output /= 48
          when 'red onion'
            output = output * 3 / 48
          when 'strawberry'
            output = output * 8 / 48
          when 'yellow bell pepper'
            output /= 48
          end

        when 'bunch'
          case name
          when 'cilantro'
            output /= 48
          end

        when 'clove'
          output

        when 'slice'
          case name
          when 'ginger'
            output *= 3
          end

        # when 'lb'
          # case name
          # when 'baby spinach'
          #   output = lb_to_kg(output * 0.03 / 48)
          # when 'sirloin steak'
          #   output = output / 2 / 48
          # when 'spinach'
          #   output = lb_to_kg(output * 0.03 / 48)
          # end

        when 'kg'
          case name
          # when 'baby spinach'
          #   output = output * 0.03 / 48
          when 'butter'
            output = output * 0.227 / 48
          when 'cheddar cheese'
            output = output * 0.113 / 48
          when 'firm tofu'
            output = output * 0.2520273 / 48
          when 'frozen corn'
            output = output * 0.165 / 48
          when 'ground oat'
            output = output * 0.088 / 48
          when 'kidney bean'
            output = lb_to_kg(output / 6.5 / 48)
          when 'mozzarella cheese'
            output = output * 0.113 / 48
          when 'raisin'
            output = output * 0.15 / 48
          when 'sirloin steak'
            output = lb_to_kg(output / 2 / 48)
          # when 'spinach'
          #   output = output * 0.03 / 48
          end

        when 'cup'
          output /= 48

        when 'tbsp'
          output /= 3
        end
      end

      if unit_input == 'kg'
        case unit_output
        when 'cup'
          case name
          when 'baby spinach'
            output /= 0.03
          when 'sirloin steak'
            output = lb_to_kg(output * 2)
          when 'spinach'
            output /= 0.03
          end
          
        # when 'slice'
        #   case name
        #   when 'cheddar cheese'
        #     output = kg_to_lb(output) * 20
        #   end
        end
      end

      if unit_input == 'lb'
        case unit_output
        when 'cup'
          case name
          when 'baby spinach'
            output = kg_to_lb(output / 0.03)
          when 'sirloin steak'
            output *= 2
          when 'spinach'
            output = kg_to_lb(output / 0.03)
          end

        when 'slice'
          case name
          when 'cheddar cheese'
            output *= 20
          end

        when 'kg'
          output = lb_to_kg(output)
        end        
      end

      if unit_input == 'slice'
        case unit_output
        # when 'lb'
        #   case name
        #   when 'cheddar cheese'
        #     output /= 20
        #   end
        # end

        when 'kg'
          case name
          when 'cheddar cheese'
            output = lb_to_kg(output / 20)
          end
        end
      end

      if unit_input == ''
        case unit_output
        when 'kg'
          case name
          when 'peeled shrimp'
            output = lb_to_kg(output / 23)
          when 'shrimp'
            output = lb_to_kg(output / 23)
          end
        end
      end

      if unit_input == 'ml'
        case unit_output
        when 'cup'
          case name
          when 'almond milk'
            output /= 240
          when 'heavy cream'
            output /= 240
          when 'milk'
            output /= 237
          when 'whipping cream'
            output /= 240
          end

        when 'kg'
          case name
          when 'kidney bean'
            output /= (0.761 * 1000)
          end
        end
      end
  
      output
    end

    def cup_tbsp_tsp(quantity, unit)
      converted = {unit: unit, quantity: quantity}
      if unit == 'cup'
        if quantity < 0.2
          converted[:unit] = 'tbsp'
          converted[:quantity] /= 0.0625
          if converted[:quantity] < 1
            converted[:unit] = 'tsp'
            converted[:quantity] /= 0.333
          end
        end
      end
  
      if unit == 'tbsp'
        if quantity > 3
          converted[:unit] = 'cup'
          converted[:quantity] /= 16
        end
  
        if quantity <= 0.666
          converted[:unit] = 'tsp'
          converted[:quantity] *= 3
        end
      end
  
      if unit == 'tsp'
        if quantity >= 12
          converted[:unit] = 'cup'
          converted[:quantity] /= 48
        end
  
        if quantity >= 3
          converted[:unit] = 'tbsp'
          converted[:quantity] /= 3
        end
      end
  
      converted
    end

    def kg_g(quantity, unit)
      converted = {unit: unit, quantity: quantity}
      if unit == 'kg'
        if quantity < 1
          converted[:unit] = 'g'
          converted[:quantity] = converted[:quantity].round(3) * 1000
        end
      end
  
      if unit == 'g'
        if quantity >= 1000
          converted[:unit] = 'kg'
          converted[:quantity] /= 1000
        end
      end  
      converted
    end

    def lb_oz(quantity, unit)
      converted = {unit: unit, quantity: quantity}
      if unit == 'lb'
        if quantity < (1/4)
          converted[:unit] = 'oz'
          converted[:quantity] *= 16
        end
      end
  
      if unit == 'oz'
        if quantity >= 4
          converted[:unit] = 'lb'
          converted[:quantity] /= 16
        end
      end  
      converted
    end
  end
end
