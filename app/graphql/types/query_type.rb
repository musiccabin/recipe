module Types
  class QueryType < Types::BaseObject

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World!"
    end


    field :current_user, Types::UserType, null: true
    def current_user
      context[:current_user]
    end

    field :recommended_recipes, [Types::MyrecipeType], null: false,
      description: "Returns all unhidden recipes in the order of maximizing leftover usage"
    def recommended_recipes
      # Myrecipe.preload(:user)
      if current_user
        recommend_recipes
      else
        Myrecipe.where(is_hidden: false).order(created_at: :desc)
      end
    end

    field :popular_recipes, [Types::MyrecipeType], null: false,
      description: "Returns unhidden recipes favoured by 20%+ of users"
    def popular_recipes
      # Myrecipe.preload(:user)
      stats = {}
      Myrecipe.where(is_hidden: false).each do |recipe|
        stats[recipe] = recipe.favourites.count
      end
      user_count = User.count
      stats.delete_if {|recipe, count| count < (user_count / 5)}
      stats.sort_by! {|recipe, count| -count}
      stats.keys      
    end

    field :mealplan, [Types::MealplanType], null: true,
      description: "Returns current user's mealplan"
    def mealplan
      current_user.mealplan if current_user
    end

    field :recipes_in_mealplan, [Types::MyrecipeType], null: true,
    description: "Returns recipes in current user's mealplan"
    def recipes_in_mealplan
      recipes = []
      links = current_user.mealplan.myrecipeingredientlinks
      if links
        links.each do |link|
          recipes << link.myrecipe
        end
      end
      recipes
    end

    field :recipe_info, Types::MyrecipeType, null: true,
    description: "Returns a recipe"
    def recipe_info(:id)
      Myrecipe.find_by(id: id)
    end

    field :ingredient_list, [Types::MyrecipeingredientlinkType], null: false,
      description: "Returns a list of recipe's ingredients"
    def ingredient_list(myrecipe:)
      recipe = Myrecipe.find(myrecipe)
      if recipe.present?
        recipe.myrecipeingredientlinks
      end
    end
    
    field :leftovers, [Types::LeftoverType], null: true,
      description: "Returns user's leftovers"
    def leftovers
      user_leftovers = []
      list = current_user&.leftovers
      if list
        list.each do |leftover|
          to_add = {}
          to_add(name: Ingredient.find_by(id: leftover.ingredient)&.name, quantity: leftover.quantity, unit: leftover.unit)
          user_leftovers << to_add
        end
      end
      user_leftovers
    end

    field :top_ten_ingredients_last_week, Hash, null: true,
    description: "Returns top-10 leftover ingredients used in the last week by user"
    def top_ten_ingredients_last_week
      usages = current_user&.leftover_usages.select{|usage| usage.created_at >= (Time.now - (24*7).hours)} if current_user
      select_top_10(usages)
    end

    field :top_ten_ingredients_last_30_days, Hash, null: true,
    description: "Returns top-10 leftover ingredients used in the last 30 days by user"
    def top_ten_ingredients_last_30_days
      usages = current_user&.leftover_usages.select{|usage| usage.created_at >= (Time.now - (24*30).hours)} if current_user
      select_top_10(usages)
    end

    field :top_ten_ingredients_last_6_months, Hash, null: true,
    description: "Returns top-10 leftover ingredients used in the last 24 hours by user"
    def top_ten_ingredients_last_6_months
      usages = current_user&.leftover_usages.select{|usage| usage.created_at >= (Time.now - 6.months)} if current_user
      select_top_10(usages)
    end

    field :top_ten_ingredients_last_week_by_city, Hash, null: true,
    description: "Returns top-10 leftover ingredients used in the last week by users from the same cities"
    def top_ten_ingredients_last_week_by_city
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - (24*7).hours)}
      select_top_10_by_city(usages)
    end

    field :top_ten_ingredients_last_week_by_region, Hash, null: true,
    description: "Returns top-10 leftover ingredients used in the last week by users from the same regions"
    def top_ten_ingredients_last_week_by_region
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - (24*7).hours)}
      select_top_10_by_region(usages)
    end

    field :top_ten_ingredients_last_week_by_province, Hash, null: true,
    description: "Returns top-10 leftover ingredients used in the last week by users from the same provinces"
    def top_ten_ingredients_last_week_by_province
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - (24*7).hours)}
      select_top_10_by_province(usages)
    end

    field :top_ten_ingredients_last_30_days_by_city, Hash, null: true,
    description: "Returns top-10 leftover ingredients used in the last 30 days by users from the same city"
    def top_ten_ingredients_last_30_days_by_city
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - (24*30).hours)}
      select_top_10_by_city(usages)
    end

    field :top_ten_ingredients_last_30_days_by_region, Hash, null: true,
    description: "Returns top-10 leftover ingredients used in the last 30 days by users from the same region"
    def top_ten_ingredients_last_30_days_by_region
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - (24*30).hours)}
      select_top_10_by_region(usages)
    end

    field :top_ten_ingredients_last_30_days_by_province, Hash, null: true,
    description: "Returns top-10 leftover ingredients used in the last 30 days by users from the same province"
    def top_ten_ingredients_last_30_days_by_province
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - (24*30).hours)}
      select_top_10_by_province(usages)
    end

    field :top_ten_ingredients_last_6_months_by_city, Hash, null: true,
    description: "Returns top-10 leftover ingredients used in the last 30 days by users from the same city"
    def top_ten_ingredients_last_6_months_by_city
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - 6.months)}
      select_top_10_by_city(usages)
    end

    field :top_ten_ingredients_last_6_months_by_region, Hash, null: true,
    description: "Returns top-10 leftover ingredients used in the last 30 days by users from the same region"
    def top_ten_ingredients_last_6_months_by_region
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - 6.months)}
      select_top_10_by_region(usages)
    end

    field :top_ten_ingredients_last_6_months_by_province, Hash, null: true,
    description: "Returns top-10 leftover ingredients used in the last 30 days by users from the same province"
    def top_ten_ingredients_last_6_months_by_province
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - 6.months)}
      select_top_10_by_province(usages)
    end
    
    field :groceries, [Types::GroceryType], null: true,
    description: "Returns user's grocery items"
    def groceries
      current_user&.groceries if current_user
    end

    field :all_dietary_restrictions, [Types::DietaryrestrictionType], null: true,
    description: "Returns all dietary restrictions"
    def all_dietary_restrictions
      Dietaryrestriction.all
    end

    field :user_dietary_restrictions, [Types::DietaryrestrictionType], null: true,
    description: "Returns user's dietary restrictions"
    def user_dietary_restrictions
      current_user.dietaryrestrictions
    end

    field :all_tags, [Types::TagType], null: true,
    description: "Returns all tags"
    def all_tags
      Tags.all
    end

    field :user_tags, [Types::TagType], null: true,
    description: "Returns user's tags"
    def all_tags
      current_user.tags
    end
  
    private
    def recommend_recipes
      result_not_in_mealplan = []
      #return recipes that aren't added to user's mealplan
      if current_user.mealplan
        result_not_in_mealplan += Myrecipe.all.select{|recipe| current_user.mealplan.myrecipes.exclude?(recipe)}
      else
        result_not_in_mealplan = Myrecipe.all
      end
      #filter by user's dietary restrictions
      result_rstrn = []
      if current_user.dietaryrestrictions.any?
        current_user.dietaryrestrictions.each do |restriction|
          result_rstrn += result_not_in_mealplan.select{|recipe| recipe.dietaryrestrictions.include?(restriction)}
        end
      else
        result_rstrn = result_not_in_mealplan
      end
      if current_user.leftovers.any?
        sorted_results = []
        sorted_results += use_up_leftovers(current_user.leftovers, result_rstrn)
        #push all the rest (non-sorted) recipes from recipe bank
        result_rstrn.each do |result|
          sorted_results << result unless sorted_results.include?(result)
        end
      else
        sorted_results = result_rstrn
      end
      #return sorted results
      sorted_results
    end

    #sort recipes like so:
    #1. over 50% use on at least 3 leftover ingredients
    #2. over 5 leftover ingredients used (even if <50%)
    #3. over 50% use on at least 2 leftover ingredients
    #4. over 3 leftover ingredients used (even if <50%)
    #5. over 50% use on at least 1 leftover ingredient
    #6. recipes that include any leftover ingredients
    def use_up_leftovers(leftovers, result_rstrn)
      sorted_results = []
      stats_reg = {}
      stats_reg.default = 0
      stats_50 = {}
      stats_50.default = 0
      #if mealplan already uses up a leftover ingredient, don't recommend recipes for this ingredient anymore.
      #if mealplan uses a portion of a leftover ingredient, update recommendation to search for the remaining quantity.
      leftovers.each do |l|
        if current_user&.mealplan&.myrecipes.any?
          current_user.mealplan.myrecipes.each do |mealplan_recipe|
            mealplan_recipe.ingredients.each do |i|
              next if i != l.ingredient
              quantity_in_recipe = floatify(proper_recipe_quantity(i, mealplan_recipe, l))
              l_quantity = floatify(l.quantity)
              if l_quantity - quantity_in_recipe > 0
                l.quantity = l_quantity - quantity_in_recipe
              else
                leftovers.delete(l)
              end
            end
          end
        end
      end
      #sort recipes
      result_rstrn.each do |r|
        leftovers.each do |leftover|
          ingredient = leftover.ingredient
          next if r.myrecipeingredientlinks.find_by(ingredient: ingredient) == nil
          #compare quantities
          quantity_leftover = leftover.quantity
          quantity_recipe = proper_recipe_quantity(ingredient, r, leftover)
          if above_50_percent(quantity_recipe, quantity_leftover)
            stats_50[r] += 1
            break if stats_50[r] >= 3
          else
            stats_reg[r] += 1
            break if stats_reg[r] >= 5
          end
        end
      end
      stats_reg = stats_reg.delete_if {|recipe| stats_50.include? recipe}
      sorted_results = push_recipe(stats_50, 3, sorted_results)
      sorted_results = push_recipe(stats_reg, 5, sorted_results)
      sorted_results = push_recipe(stats_50, 2, sorted_results)
      sorted_results = push_recipe(stats_reg, 4, sorted_results)
      sorted_results = push_recipe(stats_reg, 3, sorted_results)
      sorted_results = push_recipe(stats_50, 1, sorted_results)
      sorted_results = push_recipe(stats_reg, 2, sorted_results)
      sorted_results = push_recipe(stats_reg, 1, sorted_results)
    end

    def proper_recipe_quantity(ingredient, recipe, leftover)
      link = recipe.myrecipeingredientlinks.find_by(ingredient: ingredient)
      unit_recipe = link.unit
      unit_leftover = leftover.unit.to_s
      if unit_recipe == unit_leftover
        return floatify(link.quantity)
      else
        return convert_quantity(ingredient, link.quantity, link.unit)
      end
    end

    def push_recipe(stats,val,sorted_results)
      if stats.has_value?(val)
        selected = stats.select {|k,v| v == val}
        sorted_results += selected.keys
      end
      sorted_results
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


    def above_50_percent(quantity_recipe, quantity_leftover)
      if quantity_recipe == ''
        return false
      elsif quantity_leftover.to_s == ''
        return true
      elsif floatify(quantity_recipe) >= 0.5 * floatify(quantity_leftover)
        return true
      else
        return false
      end
    end

    def select_top_10(usages)
      # remember to incorporate unit conversions later!
      top_ten = {}
      top_ten[:frozen] = []
      top_ten[:produce] = []
      top_ten[:dairy] = []
      top_ten[:meat] = []
      top_ten[:other] = []
      all_stats = []
      usages.each do |usage|
        ingredient = usage.ingredient
        stats = all_stats.detect {|e| e[:ingredient] == ingredient}
        if stats
          stats[:quantity] += usage.quantity
          stats[:count] += 1
        else
          all_stats << { ingredient: ingredient, quantity: usage.quantity, unit: usage.unit, count: 1 }
        end
      end
      all_stats.each do |stats|
        case stats.ingredient.category
        when 'frozen'
          top_ten[:frozen] << stats
        when 'produce'
          top_ten[:produce] << stats
        when 'dairy'
          top_ten[:dairy] << stats
        when 'meat'
          top_ten[:meat] << stats
        when 'other'
          top_ten[:other] << stats
        else
        end
      end
      top_ten[:frozen] = top_ten[:frozen].sort_by { |stats| -stats[:count]}.first(10)
      top_ten[:produce] = top_ten[:produce].sort_by { |stats| -stats[:count]}.first(10)
      top_ten[:dairy] = top_ten[:dairy].sort_by { |stats| -stats[:count]}.first(10)
      top_ten[:meat] = top_ten[:meat].sort_by { |stats| -stats[:count]}.first(10)
      top_ten[:other] = top_ten[:other].sort_by { |stats| -stats[:count]}.first(10)
      top_ten
    end

    def select_top_10_by_city(usages)
      all_usages = []
      usages.each do |usage|
        stats = all_usages.detect {|stats| stats[:city] == usage.user.city}
        if stats
          stats[:usage] << usage
        else
          city_usage = []
          city_usage << usage
          all_usages << { city: usage.user.city, usage: city_usage }
        end
      end
      all_usages.each do |city_hash|
        city_hash[:usage] = select_top_10(city_hash[:usage])
      end
    end

    def select_top_10_by_region(usages)
      all_usages = []
      usages.each do |usage|
        stats = all_usages.detect {|stats| stats[:region] == usage.user.region}
        if stats
          stats[:usage] << usage
        else
          region_usage = []
          region_usage << usage
          all_usages << { region: usage.user.region, usage: region_usage }
        end
      end
      all_usages.each do |region_hash|
        region_hash[:usage] = select_top_10(region_hash[:usage])
      end
    end

    def select_top_10_by_province(usages)
      all_usages = []
      usages.each do |usage|
        stats = all_usages.detect {|stats| stats[:province] == usage.user.province}
        if stats
          stats[:usage] << usage
        else
          province_usage = []
          province_usage << usage
          all_usages << { province: usage.user.province, usage: province_usage }
        end
      end
      all_usages.each do |province_hash|
        province_hash[:usage] = select_top_10(province_hash[:usage])
      end
    end
  end
end
