class WelcomeController < ApplicationController
  def index
    if current_user
      if current_user.is_admin
        @recipes = Myrecipe.all.order(created_at: :desc)
      else
        #grab recipes with user's preferences and display images
        @recipes = recommend_recipes
      end
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
        result_rstrn << Myrecipe.all.select{|recipe| recipe.dietaryrestrictions.include?(restriction)}
      end
    else
      result_rstrn = Myrecipe.all
    end
    #filter by user's tag selections
    if current_user.tags.any?
      current_user.tags.each do |tag|
        result_rstrn_tags = result_rstrn.select{|recipe| recipe.tags.include?(tag)}
      end
    else
      result_rstrn_tags = result_rstrn
    end
    #sort by user's expiring ingredients
    if current_user.leftovers.any?
      #select user's leftovers that are expiring in 3 days
      exp_leftovers = current_user.leftovers.select {|l| l.expiry_date != ''}
      exp_leftovers.each do |leftover|
        exp_leftovers.delete(leftover) unless expires_in(leftover) <= 3
      end
      #sort exp_leftovers by expiry_date
      mapped = exp_leftovers.map {|leftover| {lo: leftover, num: expires_in(leftover)}}
      exp_leftovers = mapped.sort_by(&:num)
      #select recipes with user's expiring ingredients
      exp_leftovers.each do |exp_leftover|
        result_rstrn_tags_exp_all = result_result_rstrn_tags.select {|recipe| recipe.ingredients.include?(exp_leftover)}
      end
      #sort recipes by over 50% use on at least 3 leftover ingredients, then 2, then 1
      stats = {}
      stats.default = 0
      sorted_results = []
      for r in result_rstrn_tags_exp_all do
        exp_leftovers.each do |leftover|
          ingredient = leftover.ingredient
          if r.myrecipeingredientlinks.find_by(ingredient: ingredient).quantity.to_f >= 0.5 * leftover.quantity.to_f
            stats[r] += 1
            if stats[r] >= 3
              sorted_results << r
              break
            end
          end
        end
      end
      sorted_results << stats.key(2)
      sorted_results << stats.key(1)
    else
      sorted_results = result_rstrn_tags
    end
    #sort recipes by seasonal ingredients
    sorted_results
  end

  def expires_in(leftover)
    mo = leftover.expiry_date.split('-')[0]
    day = leftover.expiry_date.split('-')[1]
    now = Time.now.strftime("%m/%d/%Y")
    cur_mo = now[0..1]
    year = "20#{now[6..7]}"
    exp_date = nil
    if mo == '01' && cur_mo == '12'
      exp_date = Date.parse("#{day}-#{mo}-#{(year.to_i +1).to_s}")
    else
      exp_date = Date.parse("#{day}-#{mo}-#{year}")
    end
    exp_date - Date.today
  end
end