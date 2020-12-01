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
          added_up << { name: ingredient_name, quantity: convert_quantity(ingredient_name, link.quantity, unit, appropriate_unit), unit: appropriate_unit }
        end
      end
  
      # subtract_leftovers = []
      added_up.each do |stats|
        ingredient = Ingredient.find_by(name: stats[:name])
        leftover = current_user.leftovers&.find_by(ingredient: ingredient)
        if leftover
          ingredient_name = ingredient.name
          stats[:quantity] -= convert_quantity(ingredient_name, leftover.quantity, leftover.unit, stats[:unit]) unless stats[:quantity].to_s == '' && is_seasoning?(ingredient_name)
          added_up.delete(stats) if stats[:quantity] <= 0
        end
      end
  
      current_user.groceries.where(:user_added => false).destroy_all
  
      added_up.each do |stats|
        if stats[:quantity] != nil && ['cup', 'tbsp', 'tsp'].include?(stats[:unit])
          converted = cup_tbsp_tsp(stats[:quantity], stats[:unit])
          stats[:unit] = converted[:unit]
          stats[:quantity] = stringify_quantity(converted[:quantity])
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
          Grocery.create(name: stats[:name], quantity: stringify_quantity(stats[:quantity]), unit: stats[:unit], user: current_user, is_completed: false) unless stats[:quantity] == '0'
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

    def appropriate_unit(name, unit)
      output = unit
  
      if is_produce?(name) || is_countable?(name)
        output = ''
    # else
    #     output ||= 'cup'
      end
      
      case name
      when 'corn'
          output = 'ear'
      when 'bacon'
          output = 'strip'
      when 'chicken bouillon'
          output = 'cube'
      when 'linguine'
          output = 'pkg'
      when 'garlic'
          output = 'clove'
      when 'cilantro'
        output = 'bunch'
      end
  
      output
    end

    def is_produce?(item)
      produce = ['cucumber', 'strawberry', 'onion', 'garlic', 'green onion', 'cilantro', 'red onion', 'yellow onion', 'jalapeno', 'corn', 'green bell pepper', 'tomato', 'avocado', 'banana', 'red chili pepper', 'oregano', 'egg']
  
      produce.include? item
    end

    def is_seasoning?(item)
      seasoning = ['salt', 'black pepper', 'cayenne pepper']
  
      seasoning.include? item
    end

    def is_countable?(item)
      countable = ['chicken breast']
  
      countable.include? item
    end

    def add_leftover_usage(recipe, ingredient, quantity, unit, old_usage_quantity, errors)
      ingredient_name = ingredient.name
      appropriate_unit = appropriate_unit(ingredient_name, unit)
      quantity_used = floatify(quantity)
      grocery = current_user.groceries.find_by(name: ingredient_name)
      quantity_bought = grocery.present? ? floatify(grocery.quantity) : 0
      if unit != appropriate_unit
        # byebug
        quantity_used = convert_quantity(ingredient_name, quantity, unit, appropriate_unit)
      end
      leftover_usage = LeftoverUsage.new(user: current_user, myrecipe: recipe)
      leftover_usage.ingredient = ingredient
      leftover = current_user.leftovers.find_by(ingredient: ingredient)
      unit_grocery = grocery&.unit
      link = recipe.myrecipeingredientlinks.find_by(ingredient: ingredient)
      quantity_bought = grocery.present? ? floatify(grocery.quantity) : 0
      if grocery.present? && grocery.unit.to_s != appropriate_unit
        quantity_bought = convert_quantity(ingredient_name, quantity_bought, unit_grocery, appropriate_unit)
      end
      if leftover.present?
        unit_leftover = leftover.unit
        quantity_leftover = leftover.quantity
        if unit_leftover != appropriate_unit
          quantity_leftover = convert_quantity(ingredient_name, quantity_leftover, unit_leftover, appropriate_unit)
        end
        if old_usage_quantity.present?
          leftover.quantity = stringify_quantity(floatify(old_usage_quantity) + floatify(quantity_leftover) - quantity_used)
        else
          leftover.quantity = stringify_quantity(quantity_bought + floatify(leftover.quantity) - quantity_used)
        end
        leftover.unit = appropriate_unit
        if leftover.quantity != '0' && ['cup', 'tbsp', 'tsp'].include?(appropriate_unit)
          converted = cup_tbsp_tsp(floatify(quantity_leftover), appropriate_unit)
          leftover.unit = converted[:unit]
          leftover.quantity = stringify_quantity(converted[:quantity])
        end
        leftover_usage.quantity = stringify_quantity(quantity_used)
        leftover_usage.unit = appropriate_unit
        if leftover_usage.save
          RecipeSchema.subscriptions.trigger("leftoverUsageAdded", {}, leftover_usage)
          usage_link = LeftoverUsageMealplanLink.new(mealplan: current_user.mealplan, leftover_usage: leftover_usage)
          usage_link.save
          leftover_usage.update(mealplan: current_user.mealplan, leftover_usage_mealplan_link: usage_link)
        else
          errors << leftover_usage.errors
        end
        if leftover.save
          if ['0', ''].include?(leftover.quantity)
            leftover.destroy
          else
            RecipeSchema.subscriptions.trigger("leftoverAdded", {}, leftover)
          end
        else
          errors << leftover.errors
        end
      else
        new_leftover = Leftover.new(user: current_user)
        new_leftover.ingredient = ingredient
        if old_usage_quantity.present?
          new_leftover.quantity = stringify_quantity(floatify(old_usage_quantity) - quantity_used)
          leftover_usage = LeftoverUsage.new(user: current_user, ingredient: ingredient, quantity: stringify_quantity(quantity_used), unit: appropriate_unit, myrecipe: recipe)
          if leftover_usage.save
            RecipeSchema.subscriptions.trigger("leftoverUsageAdded", {}, leftover_usage)
            usage_link = LeftoverUsageMealplanLink.new(mealplan: current_user.mealplan, leftover_usage: leftover_usage)
            usage_link.save
            leftover_usage.update(mealplan: current_user.mealplan, leftover_usage_mealplan_link: usage_link)
          else
            errors << leftover_usage.errors
          end
        else
          new_leftover.quantity = stringify_quantity(quantity_bought - quantity_used)
        end
        new_leftover.unit = appropriate_unit
        if ['cup', 'tbsp', 'tsp'].include? appropriate_unit
          converted = cup_tbsp_tsp(floatify(new_leftover.quantity), appropriate_unit)
          new_leftover.unit = converted[:unit]
          new_leftover.quantity = stringify_quantity(converted[:quantity])
        end
        if new_leftover.save
          if ['', '0'].include?(new_leftover.quantity)
            new_leftover.destroy
          else
            RecipeSchema.subscriptions.trigger("leftoverAdded", {}, leftover)
          end
        else
          errors << new_leftover.errors
        end
      end
      errors
    end

    def add_ingredients_to_recipe(recipe, ingredients)
      ingredients.each do |i|
        if i.quantity.to_s == ''
          raise GraphQL::ExecutionError,
                "Ingredient must have a quantity. Please enter 'to taste' for seasoning."
        end
        ingredient = Ingredient.find_or_initialize_by(name: i.ingredient_name)
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

    def convert_quantity(name, quantity, unit_input, unit_output)
      return 0 if ['to taste', ''].include? quantity.to_s
      output = floatify(quantity)
      if unit_input == 'cup'
        case unit_output
        when ''
          case name
          when 'green bell pepper'
            output
          when 'red bell pepper'
            output
          when 'yellow bell pepper'
            output
          when 'cilantro'
            output
          when 'green onion'
            output *= 9
          when 'strawberry'
            output *= 8
          when 'cucumber'
            output /= 2
          when 'avocado'
            output /= 2
          when 'red onion'
            output *= 3
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
          when 'green bell pepper'
            output /= 16
          when 'red bell pepper'
            output /= 16
          when 'yellow bell pepper'
            output /= 16
          when 'cilantro'
            output /= 16
          when 'green onion'
            output = output * 9 / 16
          when 'strawberry'
            output = output * 8 / 16
          when 'cucumber'
            output = output / 2 / 16
          when 'avocado'
            output = output / 2 / 16
          when 'red onion'
            output = output * 3 / 16
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
          when 'green bell pepper'
            output /= 48
          when 'red bell pepper'
            output /= 48
          when 'yellow bell pepper'
            output /= 48
          when 'cilantro'
            output /= 48
          when 'green onion'
            output = output * 9 / 48
          when 'strawberry'
            output = output * 8 / 48
          when 'cucumber'
            output = output / 2 / 48
          when 'avocado'
            output = output / 2 / 48
          when 'red onion'
            output = output * 3 / 48
          end
        when 'cup'
          output /= 48
        when 'tbsp'
          output /= 3
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
  end
end
