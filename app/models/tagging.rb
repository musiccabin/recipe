class Tagging < ApplicationRecord
  belongs_to :my_recipe
  belongs_to :tag

  validates :tag, presence: true, uniqueness: {scope: :my_recipe}
end
