class RenameDietaryRestrictionLink < ActiveRecord::Migration[5.2]
  def change
    rename_table :dietary_restriction_links, :dietaryrestrictionlinks
  end
end
