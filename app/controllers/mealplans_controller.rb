class MealplansController < ApplicationController

  before_action :find_recipe

  def create
    @mealplan = Mealplan.new(user: current_user)
    @myrecipe.mealplan = @mealplan
  end

  def show
  end

  def update
  end

  def destroy
  end

  private
  def find_recipe
    @myrecipe = Myrecipe.find_by(id: params[:id])
  end
end
