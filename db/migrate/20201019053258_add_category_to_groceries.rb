class AddCategoryToGroceries < ActiveRecord::Migration[5.2]
  def change
    add_column :groceries, :category, :string
  end
end
