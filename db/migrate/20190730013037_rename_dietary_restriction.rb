class RenameDietaryRestriction < ActiveRecord::Migration[5.2]
  def change
    rename_table :dietary_restrictions, :dietaryrestrictions
  end
end
