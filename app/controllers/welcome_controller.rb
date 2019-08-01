class WelcomeController < ApplicationController
  def index
    if current_user
      #grab recipes with user's preferences and display images
    else
      @recipes = MyRecipe.where(is_hidden: false)
      #grab "ranodm" recipes and display images
    end
  end
end