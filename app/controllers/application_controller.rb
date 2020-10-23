class ApplicationController < ActionController::Base
  private
  def current_user
      if session[:user_id].present?
          @current_user ||= User.find(session[:user_id])
      end
  end
  helper_method(:current_user)

  def is_produce?(item)
    produce = ['cucumber', 'strawberry', 'onion', 'garlic', 'green onions', 'onion', 'red onion', 'yellow onion', 'jalapeno', 'corn', 'green bell pepper', 'tomato', 'avocado', 'banana', 'red chili pepper', 'oregano', 'egg']

    produce.include? item
  end
  helper_method(:is_produce?)

  def is_seasoning?(item)
    seasoning = ['salt', 'black pepper', 'cayenne pepper']

    seasoning.include? item
  end
  helper_method(:is_seasoning?)

  #info from: https://bcfarmersmarket.org/why-bc-farmers-markets/whats-in-season/
  def seasonal_ingredients
    output = []
    now = Time.now.strftime("%m/%d/%Y")
    cur_mo = now[0..1]
    case cur_mo
    when '10'
      output = ['apple', 'artichoke', 'beet', 'broccoli', 'brussels sprouts', 'green cabbage', 'red cabbage', 'savoy cabbage', 'carrot', 'cauliflower', 'celery', 'corn', 'cranberry', 'cucumber', 'fennel bulb', 'garlic', 'kale', 'kiwi', 'leek', 'lettuce', 'mustard greens', 'red onion', 'yellow onion', 'parsnip', 'pear', 'pepper', 'potato', 'pumpkin', 'quince', 'radish', 'rutabaga', 'spinach', 'squash', 'swiss chard', 'tomato', 'turnip', 'zucchini', 'bean', 'shallot']
    when '11'
      output = ['apple', 'beet', 'broccoli', 'brussels sprouts', 'green cabbage', 'red cabbage', 'savoy cabbage', 'carrot', 'cauliflower', 'kale', 'kiwi', 'leek', 'lettuce', 'mustard greens', 'red onion', 'yellow onion', 'parsnip', 'pear', 'potato', 'pumpkin', 'quince', 'rutabaga', 'squash', 'swiss chard', 'tomato', 'turnip', 'bean', 'garlic', 'shallot']
    else
      output = []
    end
  end

  def is_in_season?(item)
    if item.include? 'potato'
      item = 'potato'
    elsif item.include?('pepper') && !item.include?('black')
      item = 'pepper'
    elsif item.include? 'squash'
      item = 'squash'
    elsif item == 'onion' && (seasonal_ingredients.include?('red onion') || seasonal_ingredients.include?('yellow onion') || seasonal_ingredients.include?('white onion'))
      return true
    end
    seasonal_ingredients.include? item
  end
  helper_method(:is_in_season?)

  def floatify(quantity)
    return quantity if quantity.is_a? Float
    output = 0
    quantity = quantity.to_s.lstrip.reverse.lstrip.reverse
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

  def stringify_quantity(float)
    output = ''
    # byebug
    if float != nil
      if float.floor == float
        output += float.floor.to_s
      else
        num = float - float.floor
        if float.floor == 0
          case true
          when num >= (0.875)
            output += float.ceil.to_s
          when num >= (0.7)
            output += "3/4"
          when num >= (0.6)
            output += "2/3"
          when num >= (0.4)
            output += "1/2"
          when num >= (0.29)
            output += "1/3"
          when num >= (0.2)
            output += "1/4"
          else
            output += ''
          end
        else
          case true
          when num >= (0.875)
            output += float.ceil.to_s
          when num >= (0.7)
            output += "#{float.floor.to_s} 3/4"
          when num >= (0.6)
            output += "#{float.floor.to_s} 2/3"
          when num >= (0.4)
            output += "#{float.floor.to_s} 1/2"
          when num >= (0.29)
            output += "#{float.floor.to_s} 1/3"
          when num >= (0.125)
            output += "#{float.floor.to_s} 1/4"
          else
            output += ''
          end
        end
      end
    end
    output
  end
  helper_method(:stringify_quantity)

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
