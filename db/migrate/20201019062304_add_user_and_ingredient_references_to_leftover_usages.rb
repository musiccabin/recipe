class AddUserAndIngredientReferencesToLeftoverUsages < ActiveRecord::Migration[5.2]
  def change
    add_reference :leftover_usages, :user, foreign_key: true
    add_reference :leftover_usages, :ingredient, foreign_key: true
  end
end
