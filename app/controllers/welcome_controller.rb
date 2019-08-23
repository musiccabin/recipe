class WelcomeController < ApplicationController
  def index
    if current_user
      # if current_user.is_admin
      #   @recipes = Myrecipe.all.order(created_at: :desc)
      # else
        #grab recipes with user's preferences and display images
        @recipes = recommend_recipes
    else
      @recipes = Myrecipe.where(is_hidden: false).order(created_at: :desc)
      #grab "ranodm" recipes and display images
    end
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
      # byebug
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
      result_rstrn_tags_non_exp = result_rstrn_tags.to_a.delete_if {|r| sorted_results.include? r}
      sorted_results += use_up_leftovers(non_exp_leftovers, result_rstrn_tags_non_exp)
      ###
      result_rstrn_tags.each do |result|
        sorted_results << result unless sorted_results.include?(result)
      end
    else
      sorted_results = result_rstrn_tags
    end
    #sort recipes by seasonal ingredients
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
        ingredient = leftover[:lo].ingredient
        quantity_leftover = leftover[:lo].quantity
        next if r.myrecipeingredientlinks.find_by(ingredient: ingredient) == nil
        quantity_recipe = r.myrecipeingredientlinks.find_by(ingredient: ingredient).quantity
        if above_50_percent(quantity_recipe, quantity_leftover)
          # byebug
          stats[r] += 1
          break if stats[r] >= 3
          # if stats[r] >= 3
          #   sorted_results << r
          #   break
          # end
        end
      end
    end
    sorted_results = push_recipe(stats, 3, sorted_results)
    sorted_results = push_recipe(stats, 2, sorted_results)
    sorted_results = push_recipe(stats, 1, sorted_results)
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
    result_rstrn_tags_non_exp.each do |r|
      non_exp_leftovers.each do |leftover|
        # byebug
        ingredient = leftover.ingredient
        quantity_leftover = leftover.quantity
        next if r.myrecipeingredientlinks.find_by(ingredient: ingredient) == nil
        quantity_recipe = r.myrecipeingredientlinks.find_by(ingredient: ingredient).quantity
        # if above_50_percent(quantity_recipe, quantity_leftover)
        #   stats_50[r] += 1
        #   break if stats_50[r] >= 3
        #   # if stats_50[r] >= 3
        #   #   sorted_results << r
        #   #   break
        #   # end
        # else
        #   stats_reg[r] += 1
        #   break if stats_reg[r] >= 5
        # end
      end
    end
    sorted_results = push_recipe(stats_50, 3, sorted_results)
    sorted_results = push_recipe(stats_reg, 5, sorted_results)
    sorted_results = push_recipe(stats_50, 2, sorted_results)
    sorted_results = push_recipe(stats_reg, 4, sorted_results)
    sorted_results = push_recipe(stats_reg, 3, sorted_results)
    sorted_results = push_recipe(stats_50, 1, sorted_results)
    sorted_results = push_recipe(stats_reg, 2, sorted_results)
    sorted_results = push_recipe(stats_reg, 1, sorted_results)

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

  def push_recipe(stats,val,sorted_results)
    if stats.has_value?(val)
      selected = stats.select {|k,v| v == val}
      sorted_results += selected.keys
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
    if quantity_leftover.to_s == ''
      return true
    elsif floatify(quantity_recipe) >= 0.5 * floatify(quantity_leftover)
      return true
    else
      return false
    end
  end

  def floatify(quantity)
    output = 0
    quantity = quantity.lstrip.reverse.lstrip.reverse
    if quantity.include? ' '
      output += quantity.split(" ")[0].to_i
      to_process = quantity.split(" ")[1]
    else
      to_process = quantity
    end
    if to_process.include? '/'
      output += (to_process.split("/")[0].to_i / to_process.split("/")[1].to_i)
    else
      output += to_process.to_f
    end
    output
  end
end