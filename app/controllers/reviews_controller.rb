class ReviewsController < ApplicationController

  before_action :find_review, except: [:create]
  before_action :authorize, except: [:create]

  def create
    @review = Review.new review_params
    @review.user = current_user
    @review.myrecipe = Myrecipe.find(params[:myrecipe_id])
    @myrecipe = @review.myrecipe
    if @review.save
      redirect_to @myrecipe
    else
      @reviews = @myrecipe.reviews.order(created_at: :desc)
      redirect_to @myrecipe
    end
  end

  def edit
  end

  # def update
  #   if @review.update
  # end

  def destroy
    @review.destroy
    redirect_to @myrecipe, notice: 'gone with the wind!'
  end

  private
  def review_params
    params.require(:review).permit(:content)
  end

  def find_review
    @myrecipe = Myrecipe.find_by(id: params[:myrecipe_id])
    @review = Review.find_by(id: params[:id])
  end

  def authorize
    return redirect_to @myrecipe, alert: 'we suspect your action is not authorized.' unless can?(:crud, @review)
  end
end
