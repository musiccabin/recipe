class WelcomeController < ApplicationController
  def index
    if current_user
      #do something
    else
      #do something else
    end
  end
end
