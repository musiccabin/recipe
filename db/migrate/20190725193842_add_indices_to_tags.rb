class AddIndicesToTags < ActiveRecord::Migration[5.2]
  def change
    add_index :tags, :name
  end
end
