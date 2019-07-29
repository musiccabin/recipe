class WelcomeController < ApplicationController
  def index
    if current_user
      #grab recipes with user's preferences and display images
    else
      #grab "ranodm" recipes and display images
    end
  end
end