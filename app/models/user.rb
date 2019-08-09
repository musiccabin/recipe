class User < ApplicationRecord

    has_secure_password
    has_many :groceries, dependent: :destroy
    has_many :userdietaryrestrictionlinks, dependent: :destroy
    has_many :dietaryrestrictions, through: :userdietaryrestrictionlinks
    has_many :likes, dependent: :nullify
    has_many :favourites, dependent: :destroy
    has_many :favourite_recipes, through: :favourites, source: :myrecipe
    has_many :completions, dependent: :nullify
    has_many :completed_recipes, through: :completions, source: :myrecipe
    has_many :reviews, dependent: :nullify
    has_many :mealplans, dependent: :destroy
    has_many :meals, through: :mealplans, source: :myrecipe

    VALID_EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    validates :email, presence: true, uniqueness: true, format: VALID_EMAIL_REGEX
    validates :first_name, presence: true
    validates :last_name, presence: true
    
    before_validation :unique_tags

    has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
    validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

    private
    def unique_tags
        self.tags == tags.reject(&:blanks?).uniq unless tags == nil
    end
end
