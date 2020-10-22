class CreateLeftoverUsageMealplanLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :leftover_usage_mealplan_links do |t|
      t.references :leftover_usage
      t.references :mealplan

      t.timestamps
    end
  end
end
