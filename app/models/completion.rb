class Completion < ApplicationRecord
  belongs_to :user
  belongs_to :myrecipe

  validates :myrecipe, presence: true, uniqueness: {scope: :user}

end
