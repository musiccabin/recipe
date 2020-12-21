class CompletionsController < ApplicationController
  before_action :find_recipe, except: :leftover_popup
  before_action :authenticate_user!

  def leftover_popup
    @myrecipe = Myrecipe.find(params[:id])
    @links = @myrecipe.myrecipeingredientlinks
    @leftovers = current_user.leftovers
    leftover_usage_links = current_user.mealplan&.leftover_usage_mealplan_links
    @leftover_usages = []
    if leftover_usage_links.any?
      leftover_usage_links.each do |l|
        @leftover_usages << l.leftover_usage if l.leftover_usage.myrecipe == @myrecipe
      end
    end
    if @leftover_usages.empty?
      @links.each do |link|
        add_leftover_usage(link.ingredient, link.quantity, link.unit, '', nil)
      end
    render :leftover_popup
    end
    # byebug
    
  end
    
  def create
    @completion = Completion.new(myrecipe: @myrecipe, user: current_user)
    @links = @myrecipe.myrecipeingredientlinks
    if @completion.save
      redirect_to leftover_popup_path(@myrecipe), notice: "nice work!!"
    else
      redirect_to @myrecipe, alert: @completion.errors.full_messages.join(", ")
    end
  end

  def edit_usage
    params = edit_usage_params
    @leftover_usage = LeftoverUsage.new(user: current_user)
    ingredient = Ingredient.find_by(id: params[:id])
    @leftover_usage.ingredient = ingredient
    quantity = floatify(params[:quantity])
    unit = params[:unit]
    expiry_date = params[:expiry_date]
    old_usage = current_user.mealplan.leftover_usages.find_by(ingredient: ingredient, myrecipe: @myrecipe)
    add_leftover_usage(ingredient, quantity, unit, expiry_date, old_usage&.quantity)
    old_usage.destroy if old_usage.present?
    redirect_to leftover_popup_path(@myrecipe)
  end

  def add_leftover_usage(ingredient, quantity, unit, expiry_date, old_usage_quantity)
    # byebug
    ingredient_name = ingredient.name
    appropriate_unit = appropriate_unit(ingredient_name, unit)
    grocery = current_user.groceries.find_by(name: ingredient_name)
    quantity_bought = grocery.present? ? floatify(grocery.quantity) : 0
    if unit != appropriate_unit
      # byebug
      quantity_used = convert_quantity(ingredient_name, quantity, unit, appropriate_unit)
    else
      quantity_used = floatify(quantity)
    end
    @leftover_usage = LeftoverUsage.new(user: current_user, myrecipe: @myrecipe)
    @leftover_usage.ingredient = ingredient
    leftover = current_user.leftovers.find_by(ingredient: ingredient)
    unit_grocery = grocery&.unit
    link = @myrecipe.myrecipeingredientlinks.find_by(ingredient: ingredient)
    if grocery.present? && grocery.unit.to_s != appropriate_unit
      quantity_bought = convert_quantity(ingredient_name, quantity_bought, unit_grocery, appropriate_unit)
    end
    if leftover.present?
      # byebug
      unit_leftover = leftover.unit
      quantity_leftover = leftover.quantity
      if unit_leftover != appropriate_unit
        quantity_leftover = convert_quantity(ingredient_name, quantity_leftover, unit_leftover, appropriate_unit)
      end
      if old_usage_quantity.present?
        # byebug
        leftover.quantity = stringify_quantity(floatify(old_usage_quantity) + floatify(quantity_leftover) - quantity_used)
      else
        leftover.quantity = stringify_quantity(quantity_bought + floatify(leftover.quantity) - quantity_used)
      end
      leftover.unit = appropriate_unit
      leftover.expiry_date = expiry_date
      if leftover.quantity != '0' && ['cup', 'tbsp', 'tsp'].include?(appropriate_unit)
        converted = cup_tbsp_tsp(floatify(quantity_leftover), appropriate_unit)
        leftover.unit = converted[:unit]
        leftover.quantity = stringify_quantity(converted[:quantity])
      end
      @leftover_usage.quantity = stringify_quantity(quantity_used)
      @leftover_usage.unit = appropriate_unit
      @leftover_usage.save && leftover.save
      # byebug
      leftover.destroy if ['0', ''].include?(leftover.quantity)
      usage_link = LeftoverUsageMealplanLink.new(mealplan: current_user.mealplan, leftover_usage: @leftover_usage)
      usage_link.save
      @leftover_usage.update(mealplan: current_user.mealplan, leftover_usage_mealplan_link: usage_link)
    else
      new_leftover = Leftover.new(user: current_user)
      new_leftover.ingredient = ingredient
      if old_usage_quantity.present?
        new_leftover.quantity = stringify_quantity(floatify(old_usage_quantity) - quantity_used)
        @leftover_usage = LeftoverUsage.create(user: current_user, ingredient: ingredient, quantity: stringify_quantity(quantity_used), unit: appropriate_unit, myrecipe: @myrecipe)
        usage_link = LeftoverUsageMealplanLink.new(mealplan: current_user.mealplan, leftover_usage: @leftover_usage)
        usage_link.save
        @leftover_usage.update(mealplan: current_user.mealplan, leftover_usage_mealplan_link: usage_link)
      else
        new_leftover.quantity = stringify_quantity(quantity_bought - quantity_used)
      end
      new_leftover.unit = appropriate_unit
      new_leftover.expiry_date = expiry_date
      if ['cup', 'tbsp', 'tsp'].include? appropriate_unit
        converted = cup_tbsp_tsp(floatify(new_leftover.quantity), appropriate_unit)
        new_leftover.unit = converted[:unit]
        new_leftover.quantity = stringify_quantity(converted[:quantity])
      end
      new_leftover.save
      new_leftover.destroy if ['', '0'].include?(new_leftover.quantity)
    end
  end
  
  def destroy
    @completion = Completion.find_by(myrecipe_id: current_user.completed_recipes.find(@myrecipe.id))
    if @completion.destroy
      redirect_to @myrecipe, notice: 'this recipe has been removed from your completions.'
    else
      redirect_to @myrecipe, alert: @completion.errors.full_messages.join(", ")
    end
  end
  
  # def user_completions
  #   @completed_recipes = current_user.completed_recipes
  # end
  
  # def index
  # end
  
  # def show
  #   redirect_to @myrecipe
  # end
  
  private
  def find_recipe
    @myrecipe = Myrecipe.find(params[:myrecipe_id])
  end

  def edit_usage_params
    params.permit(:id, :quantity, :unit, :expiry_date)
  end


end
