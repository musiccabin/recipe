class Favourite < ApplicationRecord
  belongs_to :user
  belongs_to :my_recipe
end
