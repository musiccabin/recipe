class Completion < ApplicationRecord
  belongs_to :user
  belongs_to :my_recipe

  validates :my_recipe, presence: true, uniqueness: {scope: :user}

end
