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
          redirect_to new_session_path, notice: 'your password is updated. keep it handy. :)'
        end
      else
        return redirect_to password_reset_path, alert: 'it does not look like this email is registered. double-check if you entered it correctly.'
      end
    end
  end

  def setting
  end

  def create
    if current_user.update update_user_params
      redirect_to setting_path, notice: 'your information is updated.'
    else
      if current_user.authenticate(params[:password]) == false
        render 'welcome/setting', alert: 'please enter a correct current password.' and return
      end
      if (params[:password] == params[:new_password] && params[:password] != "")
        render 'welcome/setting', alert: 'your new password has to be different from your current password.' and return
      end
      if params[:new_password] != params[:password_confirmation]
        render 'welcome/setting', alert: 'please make sure password confirmation matches with new password.'
      end
    end
  end

  private
  def password_params
      params.require(:user).permit(:password, :new_password, :password_confirmation)
  end

  def can_update
    (current_user == current_user.authenticate(params[:password])) && (params[:password] != params[:new_password]) && (params[:new_password] == params[:password_confirmation]) && current_user.update({password: params[:new_password]})
  end

  def update_user_params
    params.permit(:last_name, :first_name, :email, :avatar)
  end
end