class AddPreviouslyCompletedToCompletions < ActiveRecord::Migration[5.2]
  def change
    add_column :completions, :previously_completed, :boolean, default: false
  end
end
