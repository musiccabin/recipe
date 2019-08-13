class Review < ApplicationRecord
  belongs_to :myrecipe
  belongs_to :user
  belongs_to :parent, :class_name => "Review", :foreign_key => "parent_review_id"

  has_many :likes, dependent: :nullify
  has_many :likers, through: :likes, source: :user
  has_many :child_events, :class_name => "Review", :foreign_key => "child_review_id"

  validates :content, presence: true, length: {minimum: 50}
  validates :myrecipe, presence: true, uniqueness: true
  validates :parent, uniqueness: true
end
