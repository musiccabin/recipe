class CreateDietaryRestrictions < ActiveRecord::Migration[5.2]
  def change
    create_table :dietary_restrictions do |t|
      t.string :name

      t.timestamps
    end
  end
end
