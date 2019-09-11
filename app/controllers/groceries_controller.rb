class GroceriesController < ApplicationController

    before_action :authenticate_user!
    before_action :find_grocery, only: [:update, :destroy]

    def index
        @grocery = Grocery.new
        @groceries = Grocery.where("is_completed = false AND user_id = #{current_user.id} AND user_added = false")
        @groceries_by_user = Grocery.where("is_completed = false AND user_id = #{current_user.id} AND user_added = true")
        @groceries_completed = Grocery.where("is_completed = true AND user_id = #{current_user.id}")
    end

    def create
        @grocery = Grocery.new grocery_params
        @grocery.user = current_user
        @grocery.user_added = true
        if @grocery.save
            redirect_to groceries_path
        else
            redirect_to groceries_path, alert: 'sorry: did you enter an item that is already in the list?'
        end
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

    def update
        if @grocery
            @grocery.update(quantity: params[:quantity], unit: params[:unit])
            redirect_to groceries_path
        end
    end

    def destroy
        if @grocery
            @grocery.destroy
            redirect_to groceries_path
        end
    end

    private
    def grocery_params
        params.require(:grocery).permit(:name, :quantity, :unit)
    end

    def find_grocery
        @grocery = Grocery.find_by(id: params[:id])
    end
end
