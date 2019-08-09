class CreateUserdietaryrestrictionlinks < ActiveRecord::Migration[5.2]
  def change
    create_table :userdietaryrestrictionlinks do |t|
      t.references :user, foreign_key: true
      t.references :dietaryrestriction, foreign_key: true

      t.timestamps
    end
  end
end
