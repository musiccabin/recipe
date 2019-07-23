class WelcomeController < ApplicationController
  def index
    if current_user
      #grab recipes with user's preferences and display images
    else
      #grab "ranodm" recipes and display images
    end
  end

  def forgot_password
  end

  def send_email
    if User.find_by(email: params[:email]) == nil
      redirect_to password_reset_path, alert: "it does not look like this email is registered. double-check if you entered it correctly."
    else
      PasswordResetMailer.forgot_password(User.find_by(email: params[:email])).deliver_later
      redirect_to root_path, notice: 'An email to reset your password is making its way to your inbox.'
    end
  end

  def password_reset
    if params[:email].present?
      @user = User.find_by(email: params[:email])
      if @user.present?
        if params[:new_password] != params[:password_confirmation]
          @msg = "please make sure password confirmation matches with new password."
          render :password_reset
        elsif (params[:new_password] == params[:password_confirmation] && @user.update({password: params[:new_password]}))
          redirect_to new_session_path, notice: 'your password is updated. keep it handy this time. :)'
        end
      else
        return redirect_to password_reset_path, alert: 'it does not look like this email is registered. double-check if you entered it correctly.'
      end
    end
  end

  def setting
  end

  def create
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