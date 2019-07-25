class AddUsersToDietaryRestriction < ActiveRecord::Migration[5.2]
  def change
    add_reference :dietary_restrictions, :user, foreign_key: true, index: {unique: true}
  end
end
