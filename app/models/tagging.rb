class Tagging < ApplicationRecord
  belongs_to :myrecipe
  belongs_to :tag

  validates :tag, presence: true, uniqueness: {scope: :myrecipe}
end
