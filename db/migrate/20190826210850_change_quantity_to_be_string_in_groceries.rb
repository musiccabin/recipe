class ChangeQuantityToBeStringInGroceries < ActiveRecord::Migration[5.2]
  def change
    change_column :groceries, :quantity, :string
  end
end
