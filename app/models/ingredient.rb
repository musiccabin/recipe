class Ingredient < ApplicationRecord

  has_many :myrecipeingredientlinks, dependent: :destroy
  has_many :myrecipes, through: :myrecipeingredientlinks
  has_many :quantity, through: :myrecipeingredientlinks, source: :myrecipe
  has_many :unit, through: :myrecipeingredientlinks, source: :myrecipe
  has_many :leftover_usages, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates_inclusion_of :category, :in => ['produce', 'meat', 'dairy', 'frozen', 'other'], :allow_nil => true

  before_validation :downcase_name

  private
    def downcase_name
        self.name&.downcase!
    end
end
