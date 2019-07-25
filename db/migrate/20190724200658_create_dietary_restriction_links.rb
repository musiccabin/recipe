class CreateDietaryRestrictionLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :dietary_restriction_links do |t|
      t.references :my_recipe, foreign_key: true
      t.references :dietary_restriction, foreign_key: true

      t.timestamps
    end
  end
end
