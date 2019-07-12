class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email params[:email]
    if user&.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to root_path, notice: "You are now signed in."
    else
        flash[:alert] = 'Wrong email or password'
        render :new
    end
  end

  def destroy
      session[:user_id] = nil
      redirect_to root_path, notice: "you are now logged out."
  end
end
