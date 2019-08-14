class CreateLeftovers < ActiveRecord::Migration[5.2]
  def change
    create_table :leftovers do |t|
      t.references :ingredient, foreign_key: true
      t.references :user, foreign_key: true
      t.string :quantity
      t.string :unit
      t.string :expiry_date

      t.timestamps
    end
  end
end
