class CreateMyrecipemealplanlinks < ActiveRecord::Migration[5.2]
  def change
    create_table :myrecipemealplanlinks do |t|
      t.references :mealplan, foreign_key: true
      t.references :myrecipe, foreign_key: true

      t.timestamps
    end
  end
end
