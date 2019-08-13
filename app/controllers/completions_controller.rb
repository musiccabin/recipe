class CompletionsController < ApplicationController
  before_action :find_recipe, except: :user_completions
  before_action :authenticate_user!
    
  def create
    @completion = Completion.new(myrecipe: @myrecipe, user: current_user)
    if @completion.save
      redirect_to @myrecipe, notice: "woohoo!! don't forget to leave a review to share your cooking experience."
    else
      redirect_to @myrecipe, alert: @completion.errors.full_messages.join(", ")
    end
  end
  
  def destroy
    @competion = Completion.find_by(myrecipe_id: current_user.completed_recipes.find(@myrecipe.id))
    if @completion.destroy
      redirect_to @myrecipe, notice: 'this recipe has been removed from your favourites.'
    else
      redirect_to @myrecipe, alert: @favourite.errors.full_messages.join(", ")
    end
  end
  
  def user_completions
    @completed_recipes = current_user.completed_recipes
  end
  
  def index
  end
  
  def show
    redirect_to @myrecipe
  end
  
  private
  def find_recipe
    @myrecipe = Myrecipe.find(params[:myrecipe_id])
  end
end
