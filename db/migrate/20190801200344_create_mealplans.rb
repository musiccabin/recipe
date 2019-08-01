class CreateMealplans < ActiveRecord::Migration[5.2]
  def change
    create_table :mealplans do |t|
      t.references :myrecipe, foreign_key: true, index: {unique: true}
      t.references :user, foreign_key: true, index: {unique: true}

      t.timestamps
    end
  end
end
