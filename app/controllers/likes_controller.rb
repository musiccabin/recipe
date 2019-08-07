class LikesController < ApplicationController
  before_action :find_review
  before_action :authenticate_user!
  before_action :authorize

  def create
    @like = Like.new(review_id: params[:review_id], user_id: current_user.id)
    if @like.save
      redirect_to @myrecipe, notice: 'like saved!'
    else
      redirect_to @myrecipe, alert: @like.errors.full_messages.join(", ")
    end
  end

  def destroy
    @like = @review.likes.find_by(user_id: current_user.id)
    if @like.destroy
      redirect_to @myrecipe
    else
      redirect_to @myrecipe, alert: @like.errors.full_messages.join(", ")
    end
  end

  private
  def find_review
    @myrecipe = myrecipe.find params[:myrecipe_id]
    @review = Review.find(params[:review_id])
  end

  def authorize
    find_review
    return redirect_to @myrecipe, alert: 'you cannot like your own reivew.' unless can?(:like, @review)
  end
end
