class CreateIngredients < ActiveRecord::Migration[5.2]
  def change
    create_table :ingredients do |t|
      t.string :name, index: {unique: true}
      t.float :quantity, index: {unique: true}
      t.string :unit, index: {unique: true}
      t.references :my_recipe, foreign_key: true

      t.timestamps
    end
  end
end
