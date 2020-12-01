class ApplicationController < ActionController::Base
  private
  def current_user
      if session[:user_id].present?
          @current_user ||= User.find(session[:user_id])
      end
  end
  helper_method(:current_user)

  def is_produce?(item)
    produce = ['cucumber', 'strawberry', 'onion', 'garlic', 'green onion', 'cilantro', 'red onion', 'yellow onion', 'jalapeno', 'corn', 'green bell pepper', 'tomato', 'avocado', 'banana', 'red chili pepper', 'egg']

    produce.include? item
  end
  helper_method(:is_produce?)

  def is_seasoning?(item)
    seasoning = ['salt', 'black pepper', 'cayenne pepper', 'oregano']

    seasoning.include? item
  end
  helper_method(:is_seasoning?)

  def is_countable?(item)
    countable = ['chicken breast']

    countable.include? item
  end
  helper_method(:is_countable?)

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
        output += float.floor.to_s unless float == 0
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

  def convert_quantity(name, quantity, unit_input, unit_output)
    return 0 if ['to taste', ''].include? quantity.to_s
    output = floatify(quantity)
    if unit_input == 'cup'
      case unit_output
      when ''
        case name
        when 'green bell pepper'
          output
        when 'red bell pepper'
          output
        when 'yellow bell pepper'
          output
        when 'cilantro'
          output
        when 'green onion'
          output *= 9
        when 'strawberry'
          output *= 8
        when 'cucumber'
          output /= 2
        when 'avocado'
          output /= 2
        when 'red onion'
          output *= 3
        end
      when 'tbsp'
        output *= 16
      when 'tsp'
        output *= 48
      end
    end

    if unit_input == 'tbsp'
      case unit_output
      when ''
        case name
        when 'green bell pepper'
          output /= 16
        when 'red bell pepper'
          output /= 16
        when 'yellow bell pepper'
          output /= 16
        when 'cilantro'
          output /= 16
        when 'green onion'
          output = output * 9 / 16
        when 'strawberry'
          output = output * 8 / 16
        when 'cucumber'
          output = output / 2 / 16
        when 'avocado'
          output = output / 2 / 16
        when 'red onion'
          output = output * 3 / 16
        end
      when 'cup'
        output /= 16
      when 'tsp'
        output *= 3
      end
    end

    if unit_input == 'tsp'
      case unit_output
      when ''
        case name
        when 'green bell pepper'
          output /= 48
        when 'red bell pepper'
          output /= 48
        when 'yellow bell pepper'
          output /= 48
        when 'cilantro'
          output /= 48
        when 'green onion'
          output = output * 9 / 48
        when 'strawberry'
          output = output * 8 / 48
        when 'cucumber'
          output = output / 2 / 48
        when 'avocado'
          output = output / 2 / 48
        when 'red onion'
          output = output * 3 / 48
        end
      when 'cup'
        output /= 48
      when 'tbsp'
        output /= 3
      end
    end

    output
  end
  helper_method(:convert_quantity)

  def appropriate_unit(name, unit)
    output = unit

    if is_produce?(name) || is_countable?(name)
      output = ''
  # else
  #     output ||= 'cup'
    end
    
    case name
    when 'corn'
        output = 'ear'
    when 'bacon'
        output = 'strip'
    when 'chicken bouillon'
        output = 'cube'
    when 'linguine'
        output = 'pkg'
    when 'garlic'
        output = 'clove'
    when 'cilantro'
      output = 'bunch'
    end

    output
  end
  helper_method(:appropriate_unit)

  def cup_tbsp_tsp(quantity, unit)
    converted = {unit: unit, quantity: quantity}
    if unit == 'cup'
      if quantity < 0.2
        converted[:unit] = 'tbsp'
        converted[:quantity] /= 0.0625
        if converted[:quantity] < 1
          converted[:unit] = 'tsp'
          converted[:quantity] /= 0.333
        end
      end
    end

    if unit == 'tbsp'
      if quantity > 3
        converted[:unit] = 'cup'
        converted[:quantity] /= 16
      end

      if quantity <= 0.666
        converted[:unit] = 'tsp'
        converted[:quantity] *= 3
      end
    end

    if unit == 'tsp'
      if quantity >= 12
        converted[:unit] = 'cup'
        converted[:quantity] /= 48
      end

      if quantity >= 3
        converted[:unit] = 'tbsp'
        converted[:quantity] /= 3
      end
    end

    converted
  end
  helper_method(:cup_tbsp_tsp)

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
