class ApplicationController < ActionController::Base
  private
  def current_user
      if session[:user_id].present?
          @current_user ||= User.find(session[:user_id])
      end
  end
  helper_method(:current_user)

  def is_produce?(item)
    produce = ['cucumber', 'strawberry', 'onion', 'garlic', 'green onions', 'onion', 'red onion', 'yellow onion', 'jalapeno', 'corn', 'green bell pepper', 'tomato', 'avocado', 'banana', 'red chili pepper', 'oregano']

    produce.include? item
  end
  helper_method(:is_produce?)

  def is_seasoning?(item)
    seasoning = ['salt', 'black pepper', 'cayenne pepper']

    seasoning.include? item
  end
  helper_method(:is_seasoning?)

  def floatify(quantity)
    output = 0
    quantity = quantity.lstrip.reverse.lstrip.reverse
    if quantity.include? ' '
      output += quantity.split(" ")[0].to_i
      to_process = quantity.split(" ")[1]
    else
      to_process = quantity
    end
    if to_process.include? '/'
      output += (to_process.split("/")[0].to_f / to_process.split("/")[1].to_f)
    else
      output += to_process.to_f
    end
    output
  end
  helper_method(:floatify)

   def user_signed_in?
    current_user.present?
   end
   
   helper_method(:user_signed_in?)

   def authenticate_user!
    unless user_signed_in?
        flash[:danger] = 'get access to all that juicy stuff!'
        redirect_to new_session_path
    end
   end

end
