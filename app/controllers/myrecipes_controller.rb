class MyrecipesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :find_recipe, only: [:add_ingredients, :show, :edit, :update, :destroy, :hide]
  before_action :authorize!, except: [:index, :show]

  def new
    @myrecipe = Myrecipe.new
    # @tag = Tag.new
  end

  def create
    @myrecipe = Myrecipe.new recipe_params
    @myrecipe.user = current_user
    if @myrecipe.save
      # RecipeMailer.new_recipe(@recipe).deliver_later
      redirect_to add_ingredients_path(@myrecipe)
    else render :new
    end
  end

  def add_ingredients
    @links = @myrecipe.myrecipeingredientlinks
    if params[:name] && params[:quantity]
      link = Myrecipeingredientlink.new(quantity: link_params[:quantity], unit: link_params[:unit])
      link.myrecipe = @myrecipe
      link.ingredient = Ingredient.find_or_initialize_by(name: link_params[:name])
      link.save
    end
  end

  def index
    @myrecipes = Myrecipe.order(title: :asc)
  end

  def edit
  end

  def destroy
    @myrecipe.destroy
    redirect_to myrecipes_path, notice: 'this recipe is deleted.'
  end

  def show
    hour = (@myrecipe.cooking_time_in_min / 60).floor
    min = (@myrecipe.cooking_time_in_min % 60)
    @cooking_time = "#{hour} hr #{min} min"
    @links = @myrecipe.myrecipeingredientlinks
    if @links == nil
      return render :add_ingredients, alert: 'a recipe must have ingredients.'
    end
    @instructions = []
    @myrecipe.instructions.split('\n').each do |step|
      (@instructions << step) unless step == ''
    end
    @reviews = @myrecipe.reviews
  end

  def update
    if @myrecipe.update recipe_params
      redirect_to @myrecipe
    else 
      render :edit
    end
  end

  def hide
    if @myrecipe.is_hidden
      @myrecipe.update(is_hidden: false)
      redirect_to myrecipes_path, alert: 'this recipe is available to public app users now.'
    else
      @myrecipe.update(is_hidden: true)
      redirect_to myrecipes_path, alert: 'This recipe is hidden now.'
    end
  end

  # def add_tag
  #   @tag = Tag.new(name: params[:new_tag])
  #   render html: "<script>alert('This tag already exists. Please select it from the checkboxes. ;)')</script>".html_safe unless @tag.save
  # end

  private
  def find_recipe
    @myrecipe = Myrecipe.find_by(id: params[:id])
  end

  def recipe_params
    params.require(:myrecipe).permit(:title, :cooking_time_in_string, :videoURL, :instructions, :dietaryrestriction_names, {dietaryrestriction_ids: []}, :tag_names, {tag_ids: []})
  end

  def link_params
    params.permit(:name, :quantity, :unit)
  end

  def authorize!
    redirect_to @myrecipe, alert: "permission declined." unless current_user.is_admin === true
  end
end
