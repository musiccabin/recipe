class ChangeUserPostalToRegion < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :postal, :region
  end
end
