class RenameCookingTimeInStringAtMyrecipes < ActiveRecord::Migration[5.2]
  def change
    rename_column :myrecipes, :cooking_time_in_string, :cooking_time
  end
end
