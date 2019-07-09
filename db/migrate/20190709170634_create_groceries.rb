class CreateGroceries < ActiveRecord::Migration[5.2]
  def change
    create_table :groceries do |t|
      t.string :name
      t.float :quantity
      t.string :unit
      t.boolean :is_completed, default: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
