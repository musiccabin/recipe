class MealplansController < ApplicationController

  before_action :authenticate_user!

  def show
    @links = current_user.mealplan.myrecipemealplanlinks
  end

end
