class CreateLeftoverUsages < ActiveRecord::Migration[5.2]
  def change
    create_table :leftover_usages do |t|
      t.string :quantity
      t.string :unit

      t.timestamps
    end
  end
end
