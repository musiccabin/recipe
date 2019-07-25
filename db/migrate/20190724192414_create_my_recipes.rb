class CreateMyRecipes < ActiveRecord::Migration[5.2]
  def change
    create_table :my_recipes do |t|
      t.string :title
      t.integer :cooking_time_in_min
      t.string :videoURL
      t.text :instructions

      t.timestamps
    end
  end
end
