class FavouritesController < ApplicationController
  before_action :find_recipe, except: :user_favourites
  before_action :authenticate_user!
  
  def create
    @favourite = Favourite.new(myrecipe: @myrecipe)
    @favourite.user = current_user
    if @favourite.save
      redirect_to @myrecipe, notice: 'this recipe is saved to your favourites.'
    else
      redirect_to @myrecipe, alert: @favourite.errors.full_messages.join(", ")
    end
  end

  def destroy
    @favourite = Favourite.find_by(myrecipe_id: current_user.favourite_recipes.find(@myrecipe.id))
    if @favourite.destroy
      redirect_to @myrecipe, notice: 'this recipe has been removed from your favourites.'
    else
      redirect_to @myrecipe, alert: @favourite.errors.full_messages.join(", ")
    end
  end

  # def user_favourites
  #   @favourite_recipes = current_user.favourite_recipes
  # end

  # def index
  # end

  # def show
  #   redirect_to 'myrecipes/show'
  # end

  private
  def find_recipe
    @myrecipe = Myrecipe.find(params[:myrecipe_id])
  end
end
