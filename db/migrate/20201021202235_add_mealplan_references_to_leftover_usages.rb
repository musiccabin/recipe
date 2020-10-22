class AddMealplanReferencesToLeftoverUsages < ActiveRecord::Migration[5.2]
  def change
    add_reference :leftover_usages, :mealplan, foreign_key: true
  end
end
