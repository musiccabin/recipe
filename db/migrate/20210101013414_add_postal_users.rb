class AddPostalUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :postal, :string
  end
end
