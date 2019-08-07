class AddDefaultToUnitOfMyrecipeingredientlinks < ActiveRecord::Migration[5.2]
  def change
    change_column :myrecipeingredientlinks, :unit, :string, :default => ''
  end
end
