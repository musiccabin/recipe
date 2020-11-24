class Mealplan < ApplicationRecord
  belongs_to :user

  has_many :myrecipemealplanlinks, dependent: :destroy
  has_many :myrecipes, through: :myrecipemealplanlinks
  has_many :leftover_usage_mealplan_links, dependent: :destroy
  has_many :leftover_usages, through: :leftover_usage_mealplan_links, dependent: :nullify

  validates :myrecipe, uniqueness: {scope: :user}
  validates :leftover_usage_mealplan_link, uniqueness: {scope: [:myrecipe, :user, :leftover_usage]}
end
