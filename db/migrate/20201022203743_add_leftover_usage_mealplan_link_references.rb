class AddLeftoverUsageMealplanLinkReferences < ActiveRecord::Migration[5.2]
  def change
    add_reference :leftover_usages, :leftover_usage_mealplan_link, foreign_key: true
    add_reference :mealplans, :leftover_usage_mealplan_link, foreign_key: true
  end
end
