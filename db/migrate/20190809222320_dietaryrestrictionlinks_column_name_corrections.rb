class DietaryrestrictionlinksColumnNameCorrections < ActiveRecord::Migration[5.2]
  def change
    rename_column :dietaryrestrictionlinks, :dietary_restriction_id, :dietaryrestriction_id
    rename_column :dietaryrestrictionlinks, :my_recipe_id, :myrecipe_id
  end
end
