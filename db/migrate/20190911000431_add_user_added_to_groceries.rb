class AddUserAddedToGroceries < ActiveRecord::Migration[5.2]
  def change
    add_column :groceries, :user_added, :boolean, default: false
  end
end
