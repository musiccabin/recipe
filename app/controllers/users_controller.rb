class UsersController < ApplicationController

  require 'date'

  before_action :authenticate_user!, except: [:new, :create, :forgot_password, :send_email, :password_reset]
  before_action :find_restrictions, only: [:preferences, :delete_restriction]

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
      redirect_to forgot_password_path, alert: "it does not look like this email is registered. double-check if you entered it correctly."
    else
      PasswordResetMailer.password_reset(User.find_by(email: params[:email])).deliver_later
      redirect_to root_path, notice: 'An email to reset your password is making its way to your inbox.'
    end
  end

  def password_reset
    if current_user
      @user = current_user
    end
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

  def preferences
    if params.has_key?("name")
      @restriction = Dietaryrestriction.find_by(name: params[:name])
      link = Userdietaryrestrictionlink.new(user: current_user, dietaryrestriction: @restriction)
      if link.save
        redirect_to user_preferences_path and return
      else
        render :preferences and return
      end
    end
    if (params.has_key? 'tags')
      tag_ids = params[:tags].reject(&:blank?).uniq
      if current_user.tag_ids.to_s != ''
        tag_ids.each do |id|
          current_user.tags << Tag.find_by(id: id)
        end
      end
      if (current_user.save)
        redirect_to user_preferences_path and return
      else
        render :preferences and return
      end
    end
  end

  # def add_tags
  #   p 'i got here.'
  #   if current_user.update tags_params
  #     redirect_to 'user/preferences'
  #   else
  #     render :preferences
  #   end
  # end

  def delete_restriction
    restriction = Dietaryrestriction.find(params[:id])
    current_user.userdietaryrestrictionlinks.find_by(dietaryrestriction_id: params[:id]).destroy
    redirect_to user_preferences_path
  end

  def delete_tag
    tag = Tag.find(params[:id])
    current_user.usertaggings.find_by(tag_id: params[:id]).destroy
    redirect_to user_preferences_path
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

  def favourites
    @favourites = current_user.favourite_recipes
  end

  def completions
    @completions = current_user.completed_recipes
  end

  def add_leftover
    params = leftover_params
    if params[:ingredient]
      leftover = Leftover.new(user: current_user)
      ingredient = Ingredient.find_by(name: params[:ingredient])
      if ingredient != nil
        leftover.ingredient = ingredient
      else
        return @error ='sorry, this ingredient does not exist in our system yet. if you find a recipe that uses it, please let us know.'
      end
      if params[:quantity]
        leftover.quantity = params[:quantity]
      end
      if params[:expiry_date]
        leftover.expiry_date = params[:expiry_date]
      end
      if leftover.save
        if leftover.expiry_date.present? && leftover.expiry_date != ''
          str = "#{leftover&.quantity.to_s} #{leftover&.unit.to_s} #{leftover.ingredient.name} (expiring #{leftover.expiry_date})"
        else
          str = "#{leftover&.quantity.to_s} #{leftover&.unit.to_s} #{leftover.ingredient.name}"
        end
        redirect_to add_leftover_path, notice: "#{str} is added to your leftovers."
      else
        @leftover = leftover
        render :add_leftover and return
      end
    end
  end

  def update_leftover
    params = update_leftover_params
    @leftover = Leftover.find_by(id: params[:id])
    if @leftover.update(quantity: params[:quantity], unit: params[:unit], expiry_date: params[:expiry_date])
      redirect_to add_leftover_path
    else
      render :add_leftover
    end
  end

  def delete_leftover
    @leftover = Leftover.find_by(id: params[:id])
    @leftover.destroy
    redirect_to add_leftover_path
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

  def find_restrictions
    @restrictions = current_user.dietaryrestrictions
  end

  def tags_params
    params.require(:user).permit(:tags)
  end

  def leftover_params
    params.permit(:ingredient, :quantity, :unit, :expiry_date)
  end

  def update_leftover_params
    params.permit(:id, :quantity, :unit, :expiry_date)
  end
end
