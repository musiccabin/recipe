class GroceriesController < ApplicationController

    before_action :authenticate_user!

    def index
        @grocery = Grocery.new
        @groceries = Grocery.where("is_completed = false AND user_id = #{current_user.id}")
        @groceries_completed = Grocery.where("is_completed = true AND user_id = #{current_user.id}")
    end

    def create
        @grocery = Grocery.new grocery_params
        @grocery.user = current_user
        @grocery.save
        redirect_to groceries_path
    end

    def complete_grocery
        grocery = Grocery.find_by(id: params[:id])
        if grocery.is_completed
          grocery.update(is_completed: false)
        else
          grocery.update(is_completed: true)
        end
        redirect_to groceries_path
    end

    private
    def grocery_params
        params.require(:grocery).permit(:name, :quantity, :unit)
    end
end
