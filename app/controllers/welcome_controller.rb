class WelcomeController < ApplicationController
  def index
    if current_user
      if current_user.is_admin
        @recipes = Myrecipe.all.order(created_at: :desc)
      else
        #grab recipes with user's preferences and display images
        @leftovers = current_user.leftovers
      end
    else
      @recipes = Myrecipe.where(is_hidden: false).order(created_at: :desc)
      #grab "ranodm" recipes and display images
    end
  end
end