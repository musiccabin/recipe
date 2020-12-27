class Mealplan < ApplicationRecord
  belongs_to :user

  has_many :myrecipemealplanlinks, dependent: :destroy
  has_many :myrecipes, through: :myrecipemealplanlinks
  has_many :leftover_usage_mealplan_links, dependent: :destroy
  has_many :leftover_usages, through: :leftover_usage_mealplan_links, dependent: :nullify

  # validates :myrecipes, uniqueness: {scope: :user}
  # validates :leftover_usage_mealplan_links, uniqueness: {scope: :leftover_usage}
  validate :unique_recipes
  validate :unique_usage_links

  private
  def unique_recipes
    recipes = self.myrecipes
    if recipes.any?
      self.errors.add(myrecipes: 'this recipe is already in the mealplan.') unless recipes == recipes.reject(&:blank?).uniq
    end
  end

  def unique_usage_links
    links = self.leftover_usage_mealplan_links
    if links.present? && links.any?
      usages = []
      links.each do |link|
        usages << link.leftover_usage
      end
      self.errors.add(leftover_usage_mealplan_links: 'this leftover usage already exists in the mealplan.') unless usages == usages.reject(&:blank?).uniq
    end
  end
end
