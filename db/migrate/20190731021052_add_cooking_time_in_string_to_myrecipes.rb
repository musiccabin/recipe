class AddCookingTimeInStringToMyrecipes < ActiveRecord::Migration[5.2]
  def change
    add_column :myrecipes, :cooking_time_in_string, :string
  end
end
