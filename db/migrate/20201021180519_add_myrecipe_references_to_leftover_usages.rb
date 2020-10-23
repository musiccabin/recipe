class AddMyrecipeReferencesToLeftoverUsages < ActiveRecord::Migration[5.2]
  def change
    add_reference :leftover_usages, :myrecipe, foreign_key: true
  end
end
