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
        if added_up == []
          stats = {}
          stats[:name] = link.ingredient.name
          stats[:unit] = appropriate_unit(link.ingredient, link.unit)
          stats[:quantity] = calculated_quantity(link)
          added_up << stats
        else
          ingredient_exists = false
          existing_stats = added_up.detect {|stat| stat[:name] == link.ingredient.name}
          if existing_stats.present?
            # byebug
            existing_stats[:quantity] += calculated_quantity(link) unless is_seasoning?(link.ingredient.name)
          else
            stats = {}
            stats[:name] = link.ingredient.name
            stats[:unit] = appropriate_unit(link.ingredient, link.unit)
            stats[:quantity] = calculated_quantity(link)
            added_up << stats
          end
        end
      end
  
      # subtract_leftovers
      added_up.each do |stats|
        ingredient = Ingredient.find_by(name: stats[:name])
        leftover = current_user.leftovers&.find_by(ingredient: ingredient)
        if leftover
          stats[:quantity] -= convert_quantity(ingredient, leftover.quantity, leftover.unit)
          stats[:quantity] = 0 if stats[:quantity] < 0
        end
      end
  
      current_user.groceries.where(:user_added => false).destroy_all
  
      added_up.each do |stats|
        if stats[:quantity] != nil
          if stats[:unit] == 'cup' && stats[:quantity] < 0.2
            stats[:unit] = 'tbsp'
            stats[:quantity] /= 0.0625
            if stats[:quantity] < 1
              stats[:unit] = 'tsp'
              stats[:quantity] /= 0.333
            end
          end
        end
  
        stats[:quantity] = stringify_quantity(stats[:quantity])
        
        Grocery.create(name: stats[:name], quantity: stats[:quantity], unit: stats[:unit], user: current_user, is_completed: false) unless stats[:quantity] == '0'
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

    def calculated_quantity(link)
      output = nil
      return output if is_seasoning?(link.ingredient.name)
      if link.unit == appropriate_unit(link.ingredient, link.unit)
          output = floatify(link.quantity)
      elsif link.unit == 'cup'
        case link.ingredient.name
        when 'green bell pepper'
          output = floatify(link.quantity) / 1.25
        when 'red bell pepper'
          output = floatify(link.quantity) / 1.25
        when 'yellow bell pepper'
          output = floatify(link.quantity) / 1.25
        when 'green onions'
          output = floatify(link.quantity) * 9
        when 'strawberry'
          output = floatify(link.quantity) * 8
        when 'cucumber'
          output = floatify(link.quantity) / 2
        when 'avocado'
          output = floatify(link.quantity) / 2
        when 'red onion'
          output = floatify(link.quantity) * 3
        else
          output = floatify(link.quantity)
        end
      elsif link.unit == 'tbsp'
        output = floatify(link.quantity) * 0.0625
      elsif link.unit == 'tsp'
        output = floatify(link.quantity) * 0.0625 * 0.333
      end
      output = nil if output == 0
      output
    end

    def appropriate_unit(ingredient, unit)
      output = nil
      
      case ingredient.name
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
      else
          output = nil
      end
  
      if is_produce?(ingredient.name) || is_seasoning?(ingredient.name) || is_countable?(ingredient.name)
          output ||= ''
      else
          output ||= 'cup'
      end
  
      output
    end

    def is_produce?(item)
      produce = ['cucumber', 'strawberry', 'onion', 'garlic', 'green onions', 'onion', 'red onion', 'yellow onion', 'jalapeno', 'corn', 'green bell pepper', 'tomato', 'avocado', 'banana', 'red chili pepper', 'oregano', 'egg']
  
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
      quantity_used = floatify(quantity)
      leftover_usage = LeftoverUsage.new(user: current_user, myrecipe: recipe)
      leftover_usage.ingredient = ingredient
      leftover = current_user.leftovers.find_by(ingredient: ingredient)
      grocery = current_user.groceries.find_by(name: ingredient.name)
      link = recipe.myrecipeingredientlinks.find_by(ingredient: ingredient)
      quantity_bought = grocery.present? ? floatify(grocery.quantity) : 0
      if leftover.present?
        if grocery.present? && grocery.unit != leftover.unit
          quantity_bought = convert_quantity(ingredient, quantity_bought, grocery.unit)
        end
        if unit.to_s != leftover.unit.to_s
          quantity_used = convert_quantity(ingredient, quantity_used, unit)
        end
        if old_usage_quantity.present?
          leftover.quantity = stringify_quantity(floatify(old_usage_quantity) + floatify(leftover.quantity) - quantity_used)
        else
          leftover.quantity = stringify_quantity(quantity_bought + floatify(leftover.quantity) - quantity_used)
        end
        leftover_usage.quantity = stringify_quantity(quantity_used)
        leftover_usage.unit = leftover.unit
        if leftover_usage.save
          RecipeSchema.subscriptions.trigger("leftoverUsageAdded", {}, leftover_usage)
          usage_link = LeftoverUsageMealplanLink.new(mealplan: current_user.mealplan, leftover_usage: leftover_usage)
          usage_link.save
          leftover_usage.update(mealplan: current_user.mealplan, leftover_usage_mealplan_link: usage_link)
        else
          errors << leftover_usage.errors
        end
        if leftover.save
          if leftover.quantity == '0'
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
          leftover_usage = LeftoverUsage.new(user: current_user, ingredient: ingredient, quantity: quantity, unit: unit, myrecipe: recipe)
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
        new_leftover.unit = unit
        if new_leftover.save
          if new_leftover.quantity == '0'
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

    def convert_quantity(ingredient, quantity, unit)
      output = floatify(quantity)
      case ingredient.name
      when 'cucumber'
        if unit == 'cup'
          # quantity = link.quantity
          output /= 2
        end
      when 'strawberry'
        if unit == 'cup'
          # quantity = link.quantity
          output *= 8
        end
      end
      output
    end
  end
end
