class AddUserReferencesToMyrecipes < ActiveRecord::Migration[5.2]
  def change
    add_reference :myrecipes, :user, foreign_key: true
  end
end
