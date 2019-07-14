class WelcomeController < ApplicationController
  def index
    if current_user
      #grab recipes with user's preferences and display images
    else
      #grab "ranodm" recipes and display images
    end
  end

  def setting
  end

  def create
    # p params
    # p "current password ok? #{current_user == current_user.authenticate(params[:password])}"
    # p "new passwords match? #{params[:new_password] == params[:password_confirmation]}"
    if can_update
      reset_session
      redirect_to new_session_path
      flash[:notice] = 'your password is updated.'
    else
      @errors = []
      if (params[:password] == params[:new_password])
        @errors << "your new password has to be different from your current password."
      end
      if (params[:new_password] != params[:password_confirmation])
        @errors << "please make sure password confirmation matches with new password."
      end
      render :setting
      flash[:alert] = 'your password should contain blah blah blah.'
    end
  end

  private
  def password_params
      params.require(:user).permit(:password, :new_password, :password_confirmation)
  end

  def can_update
    (current_user == current_user.authenticate(params[:password])) && (params[:password] != params[:new_password]) && (params[:new_password] == params[:password_confirmation]) && current_user.update({password: params[:new_password]})
  end
end
