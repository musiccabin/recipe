class Ingredient < ApplicationRecord

  has_many :myrecipeingredientlinks, dependent: :destroy
  has_many :myrecipes, through: :myrecipeingredientlinks
  has_many :quantity, through: :myrecipeingredientlinks, source: :myrecipe
  has_many :unit, through: :myrecipeingredientlinks, source: :myrecipe
  has_many :leftover_usages, dependent: :nullify

  validates :name, presence: true, uniqueness: true, case_sensitive: false
  validate :singular
  validate :accepted_category
  # validates_inclusion_of :category, :in => ['produce', 'meat', 'dairy', 'frozen', 'nuts & seeds', 'other'], :allow_nil => false

  before_validation :downcase_name

  private
    def downcase_name
      self.name&.downcase!
    end

    def singular
      name = self.name.downcase.strip
      # allowed = ['asparagus']
      # return if allowed.include? name
      if Ingredient.find_by(name: name.delete_suffix('es')) || Ingredient.find_by(name: name.delete_suffix('s'))
        self.errors.add(:name, 'please use singular form of ingredient name.')
      end
    end

    def accepted_category
      self.errors.add(:category, 'allowed categories: produce, meat, dairy, frozen, nuts & seeds, other') unless ['produce', 'meat', 'dairy', 'frozen', 'nuts & seeds', 'other'].include? self&.category&.downcase
    end
end
