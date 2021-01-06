class AddCompletedToMyrecipemealplanlink < ActiveRecord::Migration[5.2]
  def change
    add_column :myrecipemealplanlinks, :completed, :boolean, default: false
  end
end
