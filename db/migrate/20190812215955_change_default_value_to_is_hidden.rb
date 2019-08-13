class ChangeDefaultValueToIsHidden < ActiveRecord::Migration[5.2]
  def change
    change_column :myrecipes, :is_hidden, :boolean, :default => true
  end
end
