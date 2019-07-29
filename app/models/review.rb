class Review < ApplicationRecord
  belongs_to :my_recipe
  belongs_to :user
  belongs_to :parent, :class_name => "Review", :foreign_key => "parent_review_id"

  has_many :likes, dependent: :nullify
  has_many :child_events, :class_name => "Review", :foreign_key => "child_review_id"

  validates :my_recipe, presence: true, uniqueness: true
  validates :parent, uniqueness: true
end