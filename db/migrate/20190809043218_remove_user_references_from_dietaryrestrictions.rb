class RemoveUserReferencesFromDietaryrestrictions < ActiveRecord::Migration[5.2]
  def change
    remove_reference :dietaryrestrictions, :user, foreign_key: true
  end
end
