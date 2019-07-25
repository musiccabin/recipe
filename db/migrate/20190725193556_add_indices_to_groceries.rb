class AddIndicesToGroceries < ActiveRecord::Migration[5.2]
  def change
    add_index :groceries, :is_completed
  end
end
