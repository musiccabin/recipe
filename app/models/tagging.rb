class Tagging < ApplicationRecord
  belongs_to :my_recipe
  belongs_to :tag
end
