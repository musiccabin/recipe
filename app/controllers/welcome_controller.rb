class WelcomeController < ApplicationController

  before_action :authenticate_user!, only: [:add_to_mealplan, :remove_from_mealplan]

  def index
    if current_user
      # if current_user.is_admin
      #   @recipes = Myrecipe.all.order(created_at: :desc)
      # else
        #grab recipes with user's preferences and display images
        @recipes = recommend_recipes
      # end
    elsif params[:tag]
      tag = Tag.find_by(name: params[:tag])
      @recipes = Myrecipe.all.to_a.select {|recipe| recipe.tags.include? tag}
    else
      @recipes = Myrecipe.where(is_hidden: false).order(created_at: :desc)
      #grab "ranodm" recipes and display images
    end
  end

  def add_to_mealplan
    link = Myrecipemealplanlink.create(myrecipe: Myrecipe.find_by(id: params[:myrecipe_id]), mealplan: current_user.mealplan)
    add_groceries_from_mealplan
    redirect_to root_path, notice: "Recipe is added to your mealplan! Add any dishes you want to cook for the next few days to stay organized."
  end

  def remove_from_mealplan
    link = current_user.mealplan.myrecipemealplanlinks.find_by(myrecipe: Myrecipe.find_by(id: params[:myrecipe_id]))
    link.destroy
    add_groceries_from_mealplan
    redirect_to root_path, notice: "Alright, removed!"
  end

  private
  def recommend_recipes
    result_rstrn = []
    #filter by user's dietary restrictions
    if current_user.dietaryrestrictions.any?
      current_user.dietaryrestrictions.each do |restriction|
        result_rstrn += Myrecipe.all.select{|recipe| recipe.dietaryrestrictions.include?(restriction)}
      end
    else
      result_rstrn = Myrecipe.all
    end
    result_rstrn_tags = []
    #either filter by tag name in params
    if params[:tag]
      tag = Tag.find_by(name: params[:tag])
      result_rstrn_tags += result_rstrn.select {|recipe| recipe.tags.include? tag}
    #or filter by user's tag selections
    elsif current_user.tags.any?
      current_user.tags.each do |tag|
        result_rstrn_tags += result_rstrn.select{|recipe| recipe.tags.include?(tag)}
      end
    else
      result_rstrn_tags = result_rstrn
    end
    if current_user.leftovers.any?
      sorted_results = []
      #select user's leftovers that are expiring in 3 days
      exp_leftovers = current_user.leftovers.select {|l| l.expiry_date != ''}
      if exp_leftovers.any?
        sorted_results = dont_let_them_expire(exp_leftovers, result_rstrn_tags)
      end
      #select the rest of the leftovers
      non_exp_leftovers = current_user.leftovers.to_a.delete_if {|r| exp_leftovers.include? r}
      #delete recipes existed in sorted_results(the ones using expiring leftovers)
      result_rstrn_tags_non_exp = result_rstrn_tags.to_a.delete_if {|r| sorted_results.include? r}
      #sort and push recipes that use non-expiring leftovers
      sorted_results += use_up_leftovers(non_exp_leftovers, result_rstrn_tags_non_exp)
      #push all the rest (non-sorted) recipes from recipe bank
      result_rstrn_tags.each do |result|
        sorted_results << result unless sorted_results.include?(result)
      end
    #if user doesn't have leftovers
    else
      #sort by seasonal ingredients
      sorted_results = seasonals_first(result_rstrn_tags)
    end
    #return sorted results
    sorted_results
  end

  def dont_let_them_expire(exp_leftovers, result_rstrn_tags)
    exp_leftovers.each do |leftover|
      exp_leftovers.delete(leftover) unless expires_in(leftover) <= 3
    end
    #sort exp_leftovers by expiry_date
    mapped = exp_leftovers.map {|leftover| {lo: leftover, num: expires_in(leftover)}}
    exp_leftovers = mapped.sort_by{|lo| lo[:num]}
    #select recipes with user's expiring ingredients
    result_rstrn_tags_exp_all = []
    exp_leftovers.each do |exp_leftover|
      result_rstrn_tags_exp_all += result_rstrn_tags.select {|recipe| recipe.ingredients.include?(exp_leftover[:lo].ingredient)}
    end
    #sort recipes by over 50% use on at least 3 leftover ingredients, then 2, then 1
    stats = {}
    stats.default = 0
    sorted_results = []
    result_rstrn_tags_exp_all.each do |r|
      exp_leftovers.each do |leftover|
        l = leftover[:lo]
        ingredient = l.ingredient
        next if r.myrecipeingredientlinks.find_by(ingredient: ingredient) == nil
        #compare quantities
        quantity_leftover = l.quantity
        quantity_recipe = proper_recipe_quantity(ingredient, r, l)
        if above_50_percent(quantity_recipe, quantity_leftover)
          # byebug
          stats[r] += 1
          break if stats[r] >= 3
          # if stats[r] >= 3
          #   sorted_results << r
          #   break
          # end
        else
          stats[r] = 0
        end
      end
    end
    sorted_results = push_recipe_seasonals_first(stats, 3, sorted_results)
    sorted_results = push_recipe_seasonals_first(stats, 2, sorted_results)
    sorted_results = push_recipe_seasonals_first(stats, 1, sorted_results)
    sorted_results = push_recipe_seasonals_first(stats, 0, sorted_results)
    # if stats.has_value?(2)
    #   selected = stats.select {|k,v| v == 2}
    #   sorted_results += selected.keys
    # end
    # if stats.has_value?(1)
    #   selected = stats.select {|k,v| v == 1}
    #   sorted_results += selected.keys
    # end
    # sorted_results
  end

  #sort recipes like so:
  #1. over 50% use on at least 3 leftover ingredients
  #2. over 5 leftover ingredients used (even if <50%)
  #3. over 50% use on at least 2 leftover ingredients
  #4. over 3 leftover ingredients used (even if <50%)
  #5. over 50% use on at least 1 leftover ingredient
  #6. recipes that include any leftover ingredients
  def use_up_leftovers(non_exp_leftovers, result_rstrn_tags_non_exp)
    sorted_results = []
    stats_reg = {}
    stats_reg.default = 0
    stats_50 = {}
    stats_50.default = 0
    #if mealplan already uses up a leftover ingredient, don't recommend recipes for this ingredient anymore.
    #if mealplan uses a portion of a leftover ingredient, update recommendation to search for the remaining quantity.
    non_exp_leftovers.each do |l|
      if current_user&.mealplan&.myrecipes.any?
        current_user.mealplan.myrecipes.each do |mealplan_recipe|
          mealplan_recipe.ingredients.each do |i|
            next if i != l.ingredient
            quantity_in_recipe = floatify(proper_recipe_quantity(i, mealplan_recipe, l))
            l_quantity = floatify(l.quantity)
            if l_quantity - quantity_in_recipe > 0
              l.quantity = l_quantity - quantity_in_recipe
            else
              non_exp_leftovers.delete(l)
            end
          end
        end
      end
    end
    #sort recipes
    result_rstrn_tags_non_exp.each do |r|
      non_exp_leftovers.each do |leftover|
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
    sorted_results = push_recipe_seasonals_first(stats_50, 3, sorted_results)
    sorted_results = push_recipe_seasonals_first(stats_reg, 5, sorted_results)
    sorted_results = push_recipe_seasonals_first(stats_50, 2, sorted_results)
    sorted_results = push_recipe_seasonals_first(stats_reg, 4, sorted_results)
    sorted_results = push_recipe_seasonals_first(stats_reg, 3, sorted_results)
    sorted_results = push_recipe_seasonals_first(stats_50, 1, sorted_results)
    sorted_results = push_recipe_seasonals_first(stats_reg, 2, sorted_results)
    sorted_results = push_recipe_seasonals_first(stats_reg, 1, sorted_results)

    # if stats_reg.has_value?(5)
    #   selected = stats_reg.select {|k,v| v == 5}
    #   sorted_results += selected.keys
    # end
    # if stats_50.has_value?(2)
    #   selected = stats_50.select {|k,v| v == 2}
    #   sorted_results += selected.keys
    # end
    # if stats_reg.has_value?(4)
    #   selected = stats_reg.select {|k,v| v == 4}
    #   sorted_results += selected.keys
    # end
    # if stats_reg.has_value?(3)
    #   selected = stats_reg.select {|k,v| v == 3}
    #   sorted_results += selected.keys
    # end
    # if stats_50.has_value?(1)
    #   selected = stats_50.select {|k,v| v == 1}
    #   sorted_results += selected.keys
    # end
    # if stats_reg.has_value?(2)
    #   selected = stats_reg.select {|k,v| v == 2}
    #   sorted_results += selected.keys
    # end
    # if stats_reg.has_value?(1)
    #   selected = stats_reg.select {|k,v| v == 1}
    #   sorted_results += selected.keys
    # end
    # sorted_results
  end

  def proper_recipe_quantity(ingredient, recipe, leftover)
    link = recipe.myrecipeingredientlinks.find_by(ingredient: ingredient)
    unit_recipe = link.unit
    unit_leftover = leftover.unit.to_s
    if unit_recipe == unit_leftover
      return floatify(link.quantity)
    else
      return convert_quantity(ingredient, link, recipe, leftover)
    end
  end

  def convert_quantity(ingredient, link, recipe, leftover)
    output = link.quantity
    case ingredient.name
    when 'cucumber'
      if link.unit == 'cup'
        # quantity = link.quantity
        output = floatify(link.quantity) / 2
      end
    when 'strawberry'
      if link.unit == 'cup'
        # quantity = link.quantity
        output = floatify(link.quantity) * 8
      end
    else
      output = link.quantity
    end
    output
  end

  def push_recipe(stats,val,sorted_results)
    if stats.has_value?(val)
      selected = stats.select {|k,v| v == val}
      sorted_results += selected.keys
    end
    sorted_results
  end

  def push_recipe_seasonals_first(stats,val,sorted_results)
    if stats.has_value?(val)
      selected = stats.select {|k,v| v == val}
      sorted_results += seasonals_first(selected.keys)
    end
    sorted_results
  end

  def expires_in(leftover)
    mo = leftover.expiry_date.split('-')[0]
    day = leftover.expiry_date.split('-')[1]
    now = Time.now.strftime("%m/%d/%Y")
    cur_mo = now[0..1]
    year = "20#{now[8..9]}"
    exp_date = nil
    if mo == '01' && cur_mo == '12'
      exp_date = Date.parse("#{day}-#{mo}-#{(year.to_i +1).to_s}")
    else
      exp_date = Date.parse("#{day}-#{mo}-#{year}")
    end
    exp_date - Date.today
  end

  def above_50_percent(quantity_recipe, quantity_leftover)
    if quantity_recipe == ''
      return false
    elsif quantity_leftover.to_s == ''
      return true
    # byebug
    elsif floatify(quantity_recipe) >= 0.5 * floatify(quantity_leftover)
      return true
    else
      return false
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
      if added_up == []
        stats = {}
        stats[:name] = link.ingredient.name
        stats[:unit] = appropriate_unit(link.ingredient, link.unit)
        stats[:quantity] = calculated_quantity(link)
        added_up << stats
      else
        ingredient_exists = false
        added_up.each do |stats|
          if stats[:name] == link.ingredient.name
            stats[:quantity] += calculated_quantity(link) unless is_seasoning?(link.ingredient.name)
            ingredient_exists = true
            break
          end
        end
        if ingredient_exists == false
          stats = {}
          stats[:name] = link.ingredient.name
          stats[:unit] = appropriate_unit(link.ingredient, link.unit)
          stats[:quantity] = calculated_quantity(link)
          added_up << stats
        end
      end
    end

    # subtract_leftovers = []
    # added_up.each do |stats|
    #     if current_user&.leftovers&.find_by(ingredient: Ingredient.find_by(name: stats[:name]))
    #         stats[]
    #     else
    #         output_quantity = quantity
    #     end
    # end

    # byebug
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
      
      # current_user.groceries.destroy_all
      # byebug
      Grocery.create(name: stats[:name], quantity: stats[:quantity], unit: stats[:unit], user: current_user, is_completed: false)
    end
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

    if is_produce?(ingredient.name) || is_seasoning?(ingredient.name)
        output ||= ''
    else
        output ||= 'cup'
    end

    output
end

def stringify_quantity(float)
    output = ''
    # byebug
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

  def seasonals_first(recipes)
    myrecipes = recipes.to_a
    output = []
    count = {}
    count.default = 0
    myrecipes.each do |r|
      count[r] = 0 unless count[r] > 0
      next if count[r] == 5
      r.myrecipeingredientlinks.each do |l|
        if is_in_season? l.ingredient.name
          count[r] += 1
        end
      end
    end
    5.downto(0) do |num|
      output += push_recipe(count, num, output)
    end
    output.uniq
  end
end