class WelcomeController < ApplicationController
  def index
    if current_user
      #grab recipes with user's preferences and display images
      
    else
      @recipes = MyRecipe.where(is_hidden: false).order(created_at: :desc)
      #grab "ranodm" recipes and display images
    end
  end
end