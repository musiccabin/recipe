class UsersController < ApplicationController

  def new
      @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path
    else render :new
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

  def update
    if current_user.update update_user_params
      # if current_user.authenticate(params[:password]) == false
      #   render :setting, alert: 'please enter a correct current password.' and return
      # end
      # if (params[:password] == params[:new_password] && params[:password] != "")
      #   render :setting, alert: 'your new password has to be different from your current password.' and return
      # end
      # if params[:new_password] != params[:password_confirmation]
      #   render :setting, alert: 'please make sure password confirmation matches with new password.'
      # end
      redirect_to :setting, notice: 'your information is updated.'
    else
      render :setting
    end
  end

  private
  def user_params
      params.require(:user).permit(:last_name, :first_name, :email, :password, :password_confirmation, :avatar)
  end

  # def password_params
  #   params.require(:user).permit(:password, :new_password, :password_confirmation)
  # end

  # def can_update
  #   (current_user == current_user.authenticate(params[:password])) && (params[:password] != params[:new_password]) && (params[:new_password] == params[:password_confirmation]) && current_user.update({password: params[:new_password]})
  # end

  def update_user_params
    params.permit(:last_name, :first_name, :email, :avatar)
  end
end
