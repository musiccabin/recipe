class RemoveUniquenessOfIndexAtDietaryrestrictions < ActiveRecord::Migration[5.2]
  def change
    remove_index :dietaryrestrictions, :user_id
    add_index :dietaryrestrictions, :user_id
  end
end
