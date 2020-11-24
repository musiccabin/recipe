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
      authenticate_user!
      recommend_recipes
    end

    field :all_recipes, [Types::MyrecipeType], null: false,
      description: "Returns unhidden recipes favoured by 20%+ of users"
    def all_recipes
      # Myrecipe.preload(:user)
     
    end

    field :popular_recipes, [Types::MyrecipeType], null: false,
      description: "Returns unhidden recipes in descending order of popularity"
    def popular_recipes
      stats = {}
      Myrecipe.where(is_hidden: false).each do |recipe|
        stats[recipe] = recipe.favourites.count
      end
      popular = stats.sort_by {|recipe, count| -count}.to_h.keys
      return popular unless current_user
      restrictions = current_user.dietaryrestrictions
      if restrictions.any?
        restrictions.each do |restriction|
          popular = popular.select{|recipe| recipe.dietaryrestrictions.include?(restriction)}
        end
      end
      tags = current_user.tags
      if tags.any?
        tags.each do |tag|
          popular = popular.select{|recipe| recipe.tags.include?(tag)}
        end
      end
      popular    
    end
    

    field :mealplan, Types::MealplanType, null: true,
      description: "Returns current user's mealplan"
    def mealplan
      authenticate_user!
      current_user.mealplan
    end

    field :recipes_in_mealplan, [Types::MyrecipeType], null: true,
    description: "Returns recipes in current user's mealplan"
    def recipes_in_mealplan
      mealplan&.myrecipes
    end

    field :recipe_info, Types::MyrecipeType, null: true,
    description: "Returns a recipe" do
      argument :id, ID, required: true      
    end   
    def recipe_info(id:)
      recipe = Myrecipe.find_by(id: id)
      if recipe.present?
        return recipe
      else
        raise GraphQL::ExecutionError,
            "Recipe not found."
      end
    end

    field :ingredient_list, [Types::MyrecipeingredientlinkType], null: false,
    description: "Returns a list of recipe's ingredients" do
      argument :id, ID, required: true
    end
    def ingredient_list(id:)
      # byebug
      recipe_info(id: id)&.myrecipeingredientlinks
    end
    
    field :leftovers, [Types::LeftoverType], null: true,
      description: "Returns user's leftovers"
    def leftovers
      authenticate_user!
      current_user.leftovers
    end

    field :completed_recipes, [Types::MyrecipeType], null: true,
    description: "Returns user's completed recipes"
    def completed_recipes
      authenticate_user!
      completed_recipes = []
      completions = current_user.completions
      if completions
        completions.each do |c|
          completed_recipes << c.myrecipe
        end
      end
      completed_recipes
    end

    field :fav_recipes, [Types::MyrecipeType], null: true,
    description: "Returns user's fav recipes"
    def fav_recipes
      authenticate_user!
      fav_recipes = []
      favs = current_user&.favourites
      if favs
        favs.each do |f|
          fav_recipes << f.myrecipe
        end
      end
      fav_recipes
    end

    field :dashboard_ind_stats_last_week, Types::IndDashboardStatsType, null: false,
    description: "Returns top-10 leftover ingredients used in the last week by user"
    def dashboard_ind_stats_last_week
      authenticate_user!
      usages = current_user.leftover_usages.select{|usage| usage.created_at >= (Time.now - (24*7).hours)}
      make_stats(usages)
    end

    field :dashboard_ind_stats_last_30_days, Types::IndDashboardStatsType, null: false,
    description: "Returns top-10 leftover ingredients used in the last 30 days by user"
    def dashboard_ind_stats_last_30_days
      authenticate_user!
      usages = current_user.leftover_usages.select{|usage| usage.created_at >= (Time.now - (24*30).hours)}
      make_stats(usages)
    end

    field :dashboard_ind_stats_last_6_months, Types::IndDashboardStatsType, null: false,
    description: "Returns top-10 leftover ingredients used in the last 24 hours by user"
    def dashboard_ind_stats_last_6_months
      authenticate_user!
      usages = current_user&.leftover_usages.select{|usage| usage.created_at >= (Time.now - 6.months)}
      make_stats(usages)
    end

    field :dashboard_com_stats_last_week_by_city, [Types::ComDashboardStatsType], null: false,
    description: "Returns top-10 leftover ingredients used in the last week by users from the same cities"
    def dashboard_com_stats_last_week_by_city
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - (24*7).hours)}
      make_stats_by_city(usages) if usages
    end

    field :dashboard_com_stats_last_week_by_region, [Types::ComDashboardStatsType], null: false,
    description: "Returns top-10 leftover ingredients used in the last week by users from the same regions"
    def dashboard_com_stats_last_week_by_region
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - (24*7).hours)}
      make_stats_by_region(usages) if usages
    end

    field :dashboard_com_stats_last_week_by_province, [Types::ComDashboardStatsType], null: false,
    description: "Returns top-10 leftover ingredients used in the last week by users from the same provinces"
    def dashboard_com_stats_last_week_by_province
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - (24*7).hours)}
      make_stats_by_province(usages) if usages
    end

    field :dashboard_com_stats_last_30_days_by_city, [Types::ComDashboardStatsType], null: false,
    description: "Returns top-10 leftover ingredients used in the last 30 days by users from the same city"
    def dashboard_com_stats_last_30_days_by_city
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - (24*30).hours)}
      make_stats_by_city(usages) if usages
    end

    field :dashboard_com_stats_last_30_days_by_region, [Types::ComDashboardStatsType], null: false,
    description: "Returns top-10 leftover ingredients used in the last 30 days by users from the same region"
    def dashboard_com_stats_last_30_days_by_region
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - (24*30).hours)}
      make_stats_by_region(usages) if usages
    end

    field :dashboard_com_stats_last_30_days_by_province, [Types::ComDashboardStatsType], null: false,
    description: "Returns top-10 leftover ingredients used in the last 30 days by users from the same province"
    def dashboard_com_stats_last_30_days_by_province
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - (24*30).hours)}
      make_stats_by_province(usages) if usages
    end

    field :dashboard_com_stats_last_6_months_by_city, [Types::ComDashboardStatsType], null: false,
    description: "Returns top-10 leftover ingredients used in the last 30 days by users from the same city"
    def dashboard_com_stats_last_6_months_by_city
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - 6.months)}
      make_stats_by_city(usages) if usages
    end

    field :dashboard_com_stats_last_6_months_by_region, [Types::ComDashboardStatsType], null: false,
    description: "Returns top-10 leftover ingredients used in the last 30 days by users from the same region"
    def dashboard_com_stats_last_6_months_by_region
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - 6.months)}
      make_stats_by_region(usages) if usages
    end

    field :dashboard_com_stats_last_6_months_by_province, [Types::ComDashboardStatsType], null: false,
    description: "Returns top-10 leftover ingredients used in the last 30 days by users from the same province"
    def dashboard_com_stats_last_6_months_by_province
      usages = LeftoverUsage.select{|usage| usage.created_at >= (Time.now - 6.months)}
      make_stats_by_province(usages) if usages
    end
    
    field :groceries, [Types::GroceryType], null: true,
    description: "Returns user's grocery items"
    def groceries
      current_user.groceries
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
      Tag.all
    end

    field :user_tags, [Types::TagType], null: true,
    description: "Returns user's tags"
    def user_tags
      current_user.tags
    end
  
    private
    def authenticate_user!
      if current_user.nil?
        raise GraphQL::ExecutionError,
          "No user is signed in."
      end
    end

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
      result_rstrn_tags = []
      # #either filter by tag name in params
      # if params[:tag]
      #   tag = Tag.find_by(name: params[:tag])
      #   result_rstrn_tags += result_rstrn.select {|recipe| recipe.tags.include? tag}
      #or filter by user's tag selections
      if current_user.tags.any?
        current_user.tags.each do |tag|
          result_rstrn_tags += result_rstrn.select{|recipe| recipe.tags.include?(tag)}
        end
      else
        result_rstrn_tags = result_rstrn
      end
      if current_user.leftovers.any?
        sorted_results = []
        sorted_results += use_up_leftovers(current_user.leftovers, result_rstrn)
        #push all the rest (non-sorted) recipes from recipe bank
        result_rstrn.each do |result|
          sorted_results << result unless sorted_results.include?(result)
        end
      else
        sorted_results = result_rstrn_tags
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

    def make_stats(usages)
      # TODO: remember to incorporate unit conversions later!
      count = { frozen: 0, produce: 0, dairy: 0, meat: 0, nuts_and_seeds: 0, other: 0 }
      return {count: count} unless usages.present?
      organized_stats = {}
      organized_stats[:frozen] = []
      organized_stats[:produce] = []
      organized_stats[:dairy] = []
      organized_stats[:meat] = []
      organized_stats[:nuts_and_seeds] = []
      organized_stats[:other] = []
      all_stats = []
      usages.each do |usage|
        ingredient = usage.ingredient
        category = ingredient.category
        category = 'nuts_and_seeds' if category == 'nuts & seeds'
        stats = all_stats.detect {|e| e[:ingredient] == ingredient}
        if stats
          stats[:quantity] = stringify_quantity(floatify(stats[:quantity]) + floatify(usage.quantity))
          stats[:count] += 1
        else
          all_stats << { ingredient: ingredient, quantity: usage.quantity, unit: usage.unit, count: 1 }
        end
        # byebug
        count[category.to_sym] += 1
      end
      all_stats.each do |stats|
        case stats[:ingredient].category
        when 'frozen'
          organized_stats[:frozen] << stats
        when 'produce'
          organized_stats[:produce] << stats
        when 'dairy'
          organized_stats[:dairy] << stats
        when 'meat'
          organized_stats[:meat] << stats
        when 'nuts & seeds'
          organized_stats[:nuts_and_seeds] << stats
        when 'other'
          organized_stats[:other] << stats
        else
        end
      end
      { count: count, usages: select_top_10(organized_stats) }
    end

    def include_tied_usages(category_stats)
      return [] unless category_stats.present?
      # byebug
      num_of_stats = category_stats.count
      if num_of_stats <= 10
        category_stats
      else
        tenth_item_usage_count = category_stats[9][:count]
        if tenth_item_usage_count > category_stats[10][:count]
          category_stats.first(10)
        else
          how_many = 10
          category_stats[10..num_of_stats-1].each do |stats|
            if stats.count == tenth_item_usage_count
             how_many += 1
            else
              category_stats.first(how_many)
            end
          end
        end
      end
    end

    def select_top_10(organized_stats)
      top_ten = {}
      top_ten[:frozen] = include_tied_usages(organized_stats[:frozen]&.sort_by { |stats| -stats[:count]})
      top_ten[:produce] = include_tied_usages(organized_stats[:produce]&.sort_by { |stats| -stats[:count]})
      top_ten[:dairy] = include_tied_usages(organized_stats[:dairy]&.sort_by { |stats| -stats[:count]})
      top_ten[:meat] = include_tied_usages(organized_stats[:meat]&.sort_by { |stats| -stats[:count]})
      top_ten[:nuts_and_seeds] = include_tied_usages(organized_stats[:nuts_and_seeds]&.sort_by { |stats| -stats[:count]})
      top_ten[:other] = include_tied_usages(organized_stats[:other]&.sort_by { |stats| -stats[:count]})
      top_ten
    end

    def make_stats_by_city(usages)
      all_usages = []
      usages.each do |usage|
        stats = all_usages.detect {|stats| stats[:city] == usage.user.city.downcase}
        if stats
          stats[:geo_usage] << usage
        else
          city_usage = []
          city_usage << usage
          all_usages << { city: usage.user.city.downcase, geo_usage: city_usage }
        end
      end
      all_usages.each do |city_hash|
        city_hash[:geo_usage] = make_stats(city_hash[:geo_usage])
      end
      all_usages
    end

    def make_stats_by_region(usages)
      all_usages = []
      usages.each do |usage|
        stats = all_usages.detect {|stats| stats[:region] == usage.user.region.downcase}
        if stats
          stats[:geo_usage] << usage
        else
          region_usage = []
          region_usage << usage
          all_usages << { region: usage.user.region.downcase, geo_usage: region_usage }
        end
      end
      all_usages.each do |region_hash|
        region_hash[:geo_usage] = make_stats(region_hash[:geo_usage])
      end
      all_usages
    end

    def make_stats_by_province(usages)
      all_usages = []
      usages.each do |usage|
        stats = all_usages.detect {|stats| stats[:province] == usage.user.province.downcase}
        if stats
          stats[:geo_usage] << usage
        else
          province_usage = []
          province_usage << usage
          all_usages << { province: usage.user.province.downcase, geo_usage: province_usage }
        end
      end
      all_usages.each do |province_hash|
        province_hash[:geo_usage] = make_stats(province_hash[:geo_usage])
      end
      all_usages
    end
  end
end
